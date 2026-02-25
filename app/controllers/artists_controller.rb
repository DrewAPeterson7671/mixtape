class ArtistsController < ApplicationController
  include UserPreferable

  before_action :set_artist, only: %i[show edit update destroy]
  skip_before_action :verify_authenticity_token

  # GET /artists
  def index
    @artists = Artist.all
    @user_prefs = current_user.user_artists
      .includes(:priority, :phase, :genres, :tags)
      .index_by(&:artist_id)

    respond_to do |format|
      format.html
      format.json do
        render json: { data: @artists.map { |artist|
          pref = @user_prefs[artist.id]
          artist.as_json(only: [:id, :name, :wikipedia, :discogs, :created_at, :updated_at]).merge(
            complete: pref&.complete || false,
            rating: pref&.rating,
            genre_name: pref&.genre_name || [],
            priority_name: pref&.priority_name,
            phase_name: pref&.phase_name
          )
        } }
      end
    end
  end

  # GET /artists/1
  def show
    @user_pref = current_user_artist(@artist)

    respond_to do |format|
      format.html
      format.json do
        render json: { data: @artist.as_json(only: [:id, :name, :wikipedia, :discogs, :created_at, :updated_at]).merge(
          complete: @user_pref.complete || false,
          rating: @user_pref.rating,
          genre_name: @user_pref.genre_name,
          priority_name: @user_pref.priority_name,
          phase_name: @user_pref.phase_name
        ) }
      end
    end
  end

  # GET /artists/new
  def new
    @artist = Artist.new
    @user_pref = UserArtist.new
  end

  # GET /artists/1/edit
  def edit
    @user_pref = current_user_artist(@artist)
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

        respond_to do |format|
          format.html { redirect_to @artist, notice: "Artist was successfully created." }
          format.json do
            render json: { data: @artist.as_json(only: [:id, :name, :wikipedia, :discogs, :created_at, :updated_at]).merge(
              complete: @user_pref.complete || false,
              rating: @user_pref.rating,
              genre_name: @user_pref.genre_name,
              priority_name: @user_pref.priority_name,
              phase_name: @user_pref.phase_name
            ) }, status: :created, location: @artist
          end
        end
      else
        @user_pref = UserArtist.new(preference_params)
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @artist.errors, status: :unprocessable_entity }
        end
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
        update_artist_genres(@user_pref)
        update_artist_tags(@user_pref)
        @user_pref.save!

        respond_to do |format|
          format.html { redirect_to @artist, notice: "Artist was successfully updated." }
          format.json do
            render json: { data: @artist.as_json(only: [:id, :name, :wikipedia, :discogs, :created_at, :updated_at]).merge(
              complete: @user_pref.complete || false,
              rating: @user_pref.rating,
              genre_name: @user_pref.genre_name,
              priority_name: @user_pref.priority_name,
              phase_name: @user_pref.phase_name
            ) }, status: :ok, location: @artist
          end
        end
      else
        @user_pref = current_user_artist(@artist)
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @artist.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /artists/1
  def destroy
    current_user.user_artists.where(artist: @artist).destroy_all

    respond_to do |format|
      format.html { redirect_to artists_path, status: :see_other, notice: "Artist preferences were removed." }
      format.json { head :no_content }
    end
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
end
