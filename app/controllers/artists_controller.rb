class ArtistsController < ApplicationController
  include UserPreferable
  include ExtJsFilterable

  before_action :set_artist, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  FILTER_CONFIG = {
    name: { kind: :string, column: "artists.name" },
    genre_name: {
      kind: :habtm_list,
      join_table: "user_artist_genres", join_fk: "artist_id", base_key: "artists.id",
      user_scope: "user_artist_genres.user_id = user_artists.user_id",
      assoc_table: "genres", assoc_fk: "genre_id", assoc_column: "name"
    },
    priority_name: { kind: :list, model: Priority, column: "user_artists.priority_id" },
    phase_name:    { kind: :list, model: Phase,    column: "user_artists.phase_id" },
    complete:      { kind: :boolean, column: "user_artists.complete" },
    rating:        { kind: :number,  column: "user_artists.rating" }
  }.freeze

  SEARCH_FIELDS = {
    joins: [
      "LEFT JOIN user_artist_genres AS search_uag ON search_uag.artist_id = artists.id AND search_uag.user_id = user_artists.user_id " \
      "LEFT JOIN genres AS search_g ON search_g.id = search_uag.genre_id"
    ],
    fields: [ "artists.name", "search_g.name" ]
  }.freeze

  # GET /artists
  def index
    @artists = Artist.joins(:user_artists).where(user_artists: { user_id: current_user.id })
    @artists = apply_ext_filters(@artists).distinct
      .sort_by { |artist| artist.name.sub(/^(The|A|An)\s+/i, "").downcase }
    @user_prefs = current_user.user_artists
      .includes(:priority, :phase, :genres, :tags)
      .index_by(&:artist_id)

    render json: { data: @artists.map { |artist|
      artist_json(artist, @user_prefs[artist.id])
    } }
  end

  # GET /artists/1
  def show
    @user_pref = current_user_artist(@artist)

    render json: { data: artist_json(@artist, @user_pref) }
  end

  # POST /artists
  def create
    ActiveRecord::Base.transaction do
      @artist = Artist.find_or_initialize_by(name: artist_params[:name])
      @artist.assign_attributes(artist_params)

      if @artist.save
        @user_pref = current_user_artist(@artist)
        @user_pref.assign_attributes(preference_params)
        update_artist_genres(@user_pref)
        update_artist_tags(@user_pref)
        @user_pref.save!

        render json: { data: artist_json(@artist, @user_pref) }, status: :created, location: @artist
      else
        render json: @artist.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /artists/1
  def update
    ActiveRecord::Base.transaction do
      @artist.assign_attributes(artist_params)

      if @artist.save
        @user_pref = current_user_artist(@artist)
        @user_pref.assign_attributes(preference_params)
        @user_pref.save!
        update_artist_genres(@user_pref)
        update_artist_tags(@user_pref)

        render json: { data: artist_json(@artist, @user_pref) }, status: :ok, location: @artist
      else
        render json: @artist.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /artists/1
  def destroy
    ActiveRecord::Base.transaction do
      album_ids = @artist.album_ids
      track_ids = @artist.track_ids

      current_user.user_albums.where(album_id: album_ids).destroy_all if album_ids.any?
      current_user.user_tracks.where(track_id: track_ids).destroy_all if track_ids.any?
      current_user.user_artists.where(artist: @artist).destroy_all
    end

    head :no_content
  end

  private

  def set_artist
    @artist = Artist.find(params[:id])
  end

  def artist_params
    params.require(:artist).permit(:name, :wikipedia_discography, :discogs)
  end

  def preference_params
    params.require(:artist).permit(:rating, :complete, :priority_id, :phase_id)
  end

  def update_artist_genres(pref)
    return unless params[:artist].key?(:genre_ids)

    genre_ids = Array(params[:artist][:genre_ids]).map(&:to_i)
    pref.save! if pref.new_record?
    pref.user_artist_genres.where.not(genre_id: genre_ids).destroy_all
    genre_ids.each do |gid|
      pref.user_artist_genres.find_or_create_by!(user: current_user, artist: pref.artist, genre_id: gid)
    end
    pref.reload
  end

  def update_artist_tags(pref)
    return unless params[:artist].key?(:tag_ids)

    tag_ids = Array(params[:artist][:tag_ids]).map(&:to_i)
    pref.save! if pref.new_record?
    pref.user_artist_tags.where.not(tag_id: tag_ids).destroy_all
    tag_ids.each do |tid|
      pref.user_artist_tags.find_or_create_by!(user: current_user, artist: pref.artist, tag_id: tid)
    end
    pref.reload
  end

  def artist_json(artist, pref)
    artist.as_json(only: [ :id, :name, :wikipedia_discography, :discogs, :created_at, :updated_at ]).merge(
      complete: pref&.complete || false,
      rating: pref&.rating,
      priority_id: pref&.priority_id,
      phase_id: pref&.phase_id,
      genre_ids: pref&.genres&.map(&:id) || [],
      tag_ids: pref&.tags&.map(&:id) || [],
      genre_name: pref&.genre_name || [],
      tag_name: pref&.tags&.map(&:name) || [],
      priority_name: pref&.priority_name,
      phase_name: pref&.phase_name
    )
  end
end
