class PlaylistsController < ApplicationController
  before_action :set_playlist, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /playlists
  def index
    @playlists = current_user.playlists.includes(:genre)

    render json: { data: @playlists.as_json(
      only: [:id, :sequence, :name, :platform, :comment, :year, :source, :created_at, :updated_at],
      methods: [:genre_name]
    ) }
  end

  # GET /playlists/1
  def show
    render json: { data: @playlist }
  end

  # POST /playlists
  def create
    @playlist = current_user.playlists.build(playlist_params)

    if @playlist.save
      render json: { data: @playlist.as_json(
        only: [:id, :sequence, :name, :platform, :comment, :year, :source, :created_at, :updated_at],
        methods: [:genre_name]
      ) }, status: :created, location: @playlist
    else
      render json: @playlist.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /playlists/1
  def update
    if @playlist.update(playlist_params)
      render json: { data: @playlist.as_json(
        only: [:id, :sequence, :name, :platform, :comment, :year, :source, :created_at, :updated_at],
        methods: [:genre_name]
      ) }, status: :ok, location: @playlist
    else
      render json: @playlist.errors, status: :unprocessable_entity
    end
  end

  # DELETE /playlists/1
  def destroy
    @playlist.destroy!

    head :no_content
  end

  private

  def set_playlist
    @playlist = current_user.playlists.find(params[:id])
  end

  def playlist_params
    params.require(:playlist).permit(:sequence, :name, :platform, :comment, :genre_id, :year, :source)
  end
end
