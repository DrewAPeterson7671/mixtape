class ArtistsController < ApplicationController
  include UserPreferable

  before_action :set_artist, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /artists
  def index
    @artists = Artist.all
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
    current_user.user_artists.where(artist: @artist).destroy_all

    head :no_content
  end

  private

  def set_artist
    @artist = Artist.find(params[:id])
  end

  def artist_params
    params.require(:artist).permit(:name, :wikipedia, :discogs)
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
    artist.as_json(only: [:id, :name, :wikipedia, :discogs, :created_at, :updated_at]).merge(
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
