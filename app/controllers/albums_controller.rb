class AlbumsController < ApplicationController
  include UserPreferable

  before_action :set_album, only: %i[show edit update destroy]
  skip_before_action :verify_authenticity_token

  # GET /albums
  def index
    @albums = Album.includes(:artists, :medium, :edition, :release_type).all
    @user_prefs = current_user.user_albums
      .includes(:genres, :tags)
      .index_by(&:album_id)

    respond_to do |format|
      format.html
      format.json do
        render json: { data: @albums.map { |album|
          pref = @user_prefs[album.id]
          album.as_json(
            only: [:id, :title, :year, :created_at, :updated_at],
            methods: [:artist_name, :medium_name, :edition_name, :release_type_name]
          ).merge(
            listened: pref&.listened || false,
            rating: pref&.rating
          )
        } }
      end
    end
  end

  # GET /albums/1
  def show
    @user_pref = current_user_album(@album)

    respond_to do |format|
      format.html
      format.json do
        render json: { data: @album.as_json(
          only: [:id, :title, :year, :created_at, :updated_at],
          methods: [:artist_name, :medium_name, :edition_name, :release_type_name]
        ).merge(
          listened: @user_pref.listened || false,
          rating: @user_pref.rating
        ) }
      end
    end
  end

  # GET /albums/new
  def new
    @album = Album.new
    @user_pref = UserAlbum.new
  end

  # GET /albums/1/edit
  def edit
    @user_pref = current_user_album(@album)
  end

  # POST /albums
  def create
    ActiveRecord::Base.transaction do
      @album = Album.new(album_params)

      if @album.save
        @user_pref = current_user_album(@album)
        @user_pref.assign_attributes(preference_params)
        update_album_genres(@user_pref)
        update_album_tags(@user_pref)
        @user_pref.save!

        respond_to do |format|
          format.html { redirect_to @album, notice: "Album was successfully created." }
          format.json do
            render json: { data: @album.as_json(
              only: [:id, :title, :year, :created_at, :updated_at],
              methods: [:artist_name, :medium_name, :edition_name, :release_type_name]
            ).merge(
              listened: @user_pref.listened || false,
              rating: @user_pref.rating
            ) }, status: :created, location: @album
          end
        end
      else
        @user_pref = UserAlbum.new(preference_params)
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @album.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /albums/1
  def update
    ActiveRecord::Base.transaction do
      @album.assign_attributes(album_params)

      if @album.save
        @user_pref = current_user_album(@album)
        @user_pref.assign_attributes(preference_params)
        update_album_genres(@user_pref)
        update_album_tags(@user_pref)
        @user_pref.save!

        respond_to do |format|
          format.html { redirect_to @album, notice: "Album was successfully updated." }
          format.json do
            render json: { data: @album.as_json(
              only: [:id, :title, :year, :created_at, :updated_at],
              methods: [:artist_name, :medium_name, :edition_name, :release_type_name]
            ).merge(
              listened: @user_pref.listened || false,
              rating: @user_pref.rating
            ) }, status: :ok, location: @album
          end
        end
      else
        @user_pref = current_user_album(@album)
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @album.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /albums/1
  def destroy
    current_user.user_albums.where(album: @album).destroy_all

    respond_to do |format|
      format.html { redirect_to albums_path, status: :see_other, notice: "Album preferences were removed." }
      format.json { head :no_content }
    end
  end

  private

  def set_album
    @album = Album.find(params[:id])
  end

  def album_params
    params.require(:album).permit(:title, :year, :release_type_id, :medium_id, :edition_id, artist_ids: [])
  end

  def preference_params
    params.require(:album).permit(:rating, :listened)
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
end
