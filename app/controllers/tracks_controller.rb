class TracksController < ApplicationController
  include UserPreferable
  include ExtJsFilterable

  before_action :set_track, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  FILTER_CONFIG = {
    artist_name: {
      kind: :habtm_string,
      join_table: "artists_tracks", join_fk: "track_id", base_key: "tracks.id",
      assoc_table: "artists", assoc_fk: "artist_id", assoc_column: "name"
    },
    title: { kind: :string, column: "tracks.title" },
    album_title: {
      kind: :habtm_string,
      join_table: "album_tracks", join_fk: "track_id", base_key: "tracks.id",
      assoc_table: "albums", assoc_fk: "album_id", assoc_column: "title"
    },
    rating:      { kind: :number,  column: "user_tracks.rating" },
    medium_name: { kind: :list, model: Medium, column: "tracks.medium_id" },
    listened:    { kind: :boolean, column: "user_tracks.listened" },
    genre_name: {
      kind: :habtm_list,
      join_table: "user_track_genres", join_fk: "track_id", base_key: "tracks.id",
      user_scope: "user_track_genres.user_id = user_tracks.user_id",
      assoc_table: "genres", assoc_fk: "genre_id", assoc_column: "name"
    }
  }.freeze

  SEARCH_FIELDS = {
    joins: [
      "LEFT JOIN artists_tracks AS search_at ON search_at.track_id = tracks.id " \
      "LEFT JOIN artists AS search_a ON search_a.id = search_at.artist_id",
      "LEFT JOIN album_tracks AS search_abt ON search_abt.track_id = tracks.id " \
      "LEFT JOIN albums AS search_ab ON search_ab.id = search_abt.album_id"
    ],
    fields: [ "tracks.title", "search_a.name", "search_ab.title" ]
  }.freeze

  # GET /tracks
  def index
    @tracks = Track.joins(:user_tracks).where(user_tracks: { user_id: current_user.id })
    @tracks = apply_ext_filters(@tracks).distinct
      .includes(:artists, :album_tracks, { albums: :artists }, :medium)
    @user_prefs = current_user.user_tracks
      .includes(:genres, :tags)
      .index_by(&:track_id)
    @tracks = sort_tracks(@tracks)

    render json: { data: @tracks.map { |track|
      pref = @user_prefs[track.id]
      track_json(track, pref)
    } }
  end

  # GET /tracks/1
  def show
    @user_pref = current_user_track(@track)

    render json: { data: track_json(@track, @user_pref) }
  end

  # POST /tracks
  def create
    ActiveRecord::Base.transaction do
      @track = Track.new(track_params)

      if @track.save
        handle_album_association
        handle_album_ids_association

        @user_pref = current_user_track(@track)
        @user_pref.assign_attributes(preference_params)
        @user_pref.save!
        update_track_genres(@user_pref)
        update_track_tags(@user_pref)

        render json: { data: track_json(@track, @user_pref) }, status: :created, location: @track
      else
        render json: @track.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /tracks/1
  def update
    ActiveRecord::Base.transaction do
      @track.assign_attributes(track_params)

      if @track.save
        handle_album_association
        handle_album_ids_association

        @user_pref = current_user_track(@track)
        @user_pref.assign_attributes(preference_params)
        @user_pref.save!
        update_track_genres(@user_pref)
        update_track_tags(@user_pref)

        render json: { data: track_json(@track, @user_pref) }, status: :ok, location: @track
      else
        render json: @track.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /tracks/1
  def destroy
    current_user.user_tracks.where(track: @track).destroy_all

    head :no_content
  end

  private

  def sort_tracks(tracks)
    strip = ->(name) { name.sub(/^(The|A|An)\s+/i, "").downcase }

    case params[:sort]
    when "album_artist"
      tracks.sort_by do |t|
        album = t.albums.min_by { |a| a.title.to_s.downcase }
        album_artist = album&.artists&.map { |a| strip.call(a.name) }&.min.to_s
        [album_artist, album&.title.to_s.downcase,
         t.album_tracks.find { |at| at.album_id == album&.id }&.disc_number.to_i,
         t.album_tracks.find { |at| at.album_id == album&.id }&.position.to_i,
         t.title.to_s.downcase]
      end
    when "title"
      tracks.sort_by { |t| strip.call(t.title.to_s) }
    when "album"
      tracks.sort_by do |t|
        album = t.albums.min_by { |a| a.title.to_s.downcase }
        [album&.title.to_s.downcase,
         t.album_tracks.find { |at| at.album_id == album&.id }&.disc_number.to_i,
         t.album_tracks.find { |at| at.album_id == album&.id }&.position.to_i,
         t.title.to_s.downcase]
      end
    when "rating"
      tracks.sort_by do |t|
        pref = @user_prefs[t.id]
        [-(pref&.rating || 0),
         t.artists.map { |a| strip.call(a.name) }.min.to_s,
         t.title.to_s.downcase]
      end
    when "recent"
      tracks.sort_by { |t| -t.created_at.to_i }
    else # "artist" (default)
      tracks.sort_by do |t|
        [t.artists.map { |a| strip.call(a.name) }.min.to_s,
         t.albums.map(&:title).min.to_s.downcase,
         t.title.to_s.downcase]
      end
    end
  end

  def set_track
    @track = Track.find(params[:id])
  end

  def track_params
    params.require(:track).permit(:title, :duration, :isrc, :medium_id, artist_ids: [])
  end

  def preference_params
    params.require(:track).permit(:rating, :listened)
  end

  def handle_album_association
    return unless params[:track][:album_id].present?

    at = AlbumTrack.find_or_initialize_by(album_id: params[:track][:album_id], track_id: @track.id)
    at.position = params[:track][:position]
    at.disc_number = params[:track][:disc_number]
    at.save!
  end

  def handle_album_ids_association
    return unless params[:track].key?(:album_ids)

    desired_album_ids = Array(params[:track][:album_ids]).map(&:to_i)
    current_album_ids = @track.album_ids

    albums_to_remove = current_album_ids - desired_album_ids
    @track.album_tracks.where(album_id: albums_to_remove).destroy_all if albums_to_remove.any?

    (desired_album_ids - current_album_ids).each do |album_id|
      AlbumTrack.create!(album_id: album_id, track_id: @track.id)
    end

    @track.reload
  end

  def track_json(track, pref)
    track.as_json(
      only: [ :id, :title, :duration, :isrc, :created_at, :updated_at ],
      methods: [ :artist_name, :album_title, :medium_name ]
    ).merge(
      listened: pref&.listened || false,
      rating: pref&.rating,
      artist_ids: track.artist_ids,
      album_ids: track.album_ids,
      medium_id: track.medium_id,
      genre_ids: pref&.genres&.map(&:id) || [],
      tag_ids: pref&.tags&.map(&:id) || [],
      genre_name: pref&.genre_name || [],
      tag_name: pref&.tags&.map(&:name) || []
    )
  end

  def update_track_genres(pref)
    return unless params[:track].key?(:genre_ids)

    genre_ids = Array(params[:track][:genre_ids]).map(&:to_i)
    pref.save! if pref.new_record?
    pref.user_track_genres.where.not(genre_id: genre_ids).destroy_all
    genre_ids.each do |gid|
      pref.user_track_genres.find_or_create_by!(user: current_user, track: pref.track, genre_id: gid)
    end
    pref.reload
  end

  def update_track_tags(pref)
    return unless params[:track].key?(:tag_ids)

    tag_ids = Array(params[:track][:tag_ids]).map(&:to_i)
    pref.save! if pref.new_record?
    pref.user_track_tags.where.not(tag_id: tag_ids).destroy_all
    tag_ids.each do |tid|
      pref.user_track_tags.find_or_create_by!(user: current_user, track: pref.track, tag_id: tid)
    end
    pref.reload
  end
end
