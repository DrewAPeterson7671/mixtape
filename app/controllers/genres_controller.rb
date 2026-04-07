class GenresController < ApplicationController
  before_action :set_genre, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /genres
  def index
    @genres = current_user.genres.order(:name)

    render json: { data: @genres }
  end

  # GET /genres/1
  def show
    render json: { data: @genre }
  end

  # POST /genres
  def create
    @genre = current_user.genres.build(genre_params)

    if @genre.save
      render json: { data: @genre }, status: :created, location: @genre
    else
      render json: @genre.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /genres/1
  def update
    if @genre.update(genre_params)
      render json: { data: @genre }, status: :ok, location: @genre
    else
      render json: @genre.errors, status: :unprocessable_entity
    end
  end

  # DELETE /genres/1
  def destroy
    @genre.destroy!

    head :no_content
  end

  private

  def set_genre
    @genre = current_user.genres.find(params[:id])
  end

  def genre_params
    params.require(:genre).permit(:name)
  end
end
