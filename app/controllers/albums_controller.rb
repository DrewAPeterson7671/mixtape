class AlbumsController < ApplicationController
  include UserPreferable

  before_action :set_album, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /albums
  def index
    @albums = Album.includes(:artists, :medium, :release_type, album_tracks: { track: :artists, edition: {} }).all
    @user_prefs = current_user.user_albums
      .includes(:genres, :tags)
      .index_by(&:album_id)

    render json: { data: @albums.map { |album|
      album_json(album, @user_prefs[album.id])
    } }
  end

  # GET /albums/1
  def show
    @user_pref = current_user_album(@album)

    render json: { data: album_json(@album, @user_pref) }
  end

  # POST /albums
  def create
    ActiveRecord::Base.transaction do
      @album = Album.new(album_params)

      if @album.save
        handle_album_tracks

        @user_pref = current_user_album(@album)
        @user_pref.assign_attributes(preference_params)
        update_album_genres(@user_pref)
        update_album_tags(@user_pref)
        @user_pref.save!

        render json: { data: album_json(@album, @user_pref) }, status: :created, location: @album
      else
        render json: @album.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /albums/1
  def update
    ActiveRecord::Base.transaction do
      @album.assign_attributes(album_params)

      if @album.save
        handle_album_tracks

        @user_pref = current_user_album(@album)
        @user_pref.assign_attributes(preference_params)
        @user_pref.save!
        update_album_genres(@user_pref)
        update_album_tags(@user_pref)

        render json: { data: album_json(@album, @user_pref) }, status: :ok, location: @album
      else
        render json: @album.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /albums/1
  def destroy
    current_user.user_albums.where(album: @album).destroy_all

    head :no_content
  end

  private

  def set_album
    @album = Album.find(params[:id])
  end

  def album_params
    params.require(:album).permit(:title, :year, :release_type_id, :medium_id, artist_ids: [])
  end

  def preference_params
    params.require(:album).permit(:rating, :listened, :consider_editions)
  end

  def handle_album_tracks
    return unless params[:album].key?(:album_tracks)

    submitted = Array(params[:album][:album_tracks])
    keep_pairs = submitted.map { |at| [at[:track_id].to_i, at[:edition_id]&.to_i] }

    @album.album_tracks.each do |existing|
      pair = [existing.track_id, existing.edition_id]
      @album.album_tracks.destroy(existing) unless keep_pairs.include?(pair)
    end

    submitted.each do |at_params|
      at = @album.album_tracks.find_or_initialize_by(
        track_id: at_params[:track_id].to_i,
        edition_id: at_params[:edition_id]&.to_i
      )
      at.position = at_params[:position]
      at.disc_number = at_params[:disc_number]
      at.save!
    end

    @album.reload
  end

  def update_album_genres(pref)
    return unless params[:album].key?(:genre_ids)

    genre_ids = Array(params[:album][:genre_ids]).map(&:to_i)
    pref.save! if pref.new_record?
    pref.user_album_genres.where.not(genre_id: genre_ids).destroy_all
    genre_ids.each do |gid|
      pref.user_album_genres.find_or_create_by!(user: current_user, album: pref.album, genre_id: gid)
    end
    pref.reload
  end

  def update_album_tags(pref)
    return unless params[:album].key?(:tag_ids)

    tag_ids = Array(params[:album][:tag_ids]).map(&:to_i)
    pref.save! if pref.new_record?
    pref.user_album_tags.where.not(tag_id: tag_ids).destroy_all
    tag_ids.each do |tid|
      pref.user_album_tags.find_or_create_by!(user: current_user, album: pref.album, tag_id: tid)
    end
    pref.reload
  end

  def album_json(album, pref)
    album.as_json(
      only: [:id, :title, :year, :created_at, :updated_at],
      methods: [:artist_name, :medium_name, :release_type_name]
    ).merge(
      listened: pref&.listened || false,
      consider_editions: pref&.consider_editions || false,
      rating: pref&.rating,
      release_type_id: album.release_type_id,
      medium_id: album.medium_id,
      artist_ids: album.artist_ids,
      genre_ids: pref&.genres&.map(&:id) || [],
      tag_ids: pref&.tags&.map(&:id) || [],
      genre_name: pref&.genre_name || [],
      tag_name: pref&.tags&.map(&:name) || [],
      album_tracks: album.album_tracks.sort_by { |at| [at.disc_number || 0, at.position || 0] }.map { |at|
        {
          track_id: at.track_id,
          track_title: at.track.title,
          artist_name: at.track.artists.map(&:name),
          position: at.position,
          disc_number: at.disc_number,
          duration: at.track.duration,
          edition_id: at.edition_id,
          edition_name: at.edition&.name
        }
      }
    )
  end
end
