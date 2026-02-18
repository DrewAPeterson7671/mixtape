class PlaylistsController < ApplicationController
  before_action :set_playlist, only: %i[show edit update destroy]
  skip_before_action :verify_authenticity_token

  # GET /playlists
  def index
    @playlists = current_user.playlists.includes(:genre)

    respond_to do |format|
      format.html
      format.json do
        render json: @playlists.as_json(
          only: [:id, :sequence, :name, :platform, :comment, :year, :source],
          methods: [:genre_name]
        )
      end
    end
  end

  # GET /playlists/1
  def show
    respond_to do |format|
      format.html
      format.json { render json: @playlist }
    end
  end

  # GET /playlists/new
  def new
    @playlist = Playlist.new
  end

  # GET /playlists/1/edit
  def edit
  end

  # POST /playlists
  def create
    @playlist = current_user.playlists.build(playlist_params)

    respond_to do |format|
      if @playlist.save
        format.html { redirect_to @playlist, notice: "Playlist was successfully created." }
        format.json do
          render json: @playlist.as_json(
            only: [:id, :sequence, :name, :platform, :comment, :year, :source],
            methods: [:genre_name]
          ), status: :created, location: @playlist
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @playlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /playlists/1
  def update
    respond_to do |format|
      if @playlist.update(playlist_params)
        format.html { redirect_to @playlist, notice: "Playlist was successfully updated." }
        format.json do
          render json: @playlist.as_json(
            only: [:id, :sequence, :name, :platform, :comment, :year, :source],
            methods: [:genre_name]
          ), status: :ok, location: @playlist
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @playlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /playlists/1
  def destroy
    @playlist.destroy!

    respond_to do |format|
      format.html { redirect_to playlists_path, status: :see_other, notice: "Playlist was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_playlist
    @playlist = current_user.playlists.find(params[:id])
  end

  def playlist_params
    params.require(:playlist).permit(:sequence, :name, :platform, :comment, :genre_id, :year, :source)
  end
end
