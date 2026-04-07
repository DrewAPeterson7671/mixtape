class GenresController < ApplicationController
  include LookupAuthorizable

  before_action :set_genre, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /genres
  def index
    @genres = Genre.visible_to(current_user).order(:name)

    render json: { data: lookup_collection_json(@genres) }
  end

  # GET /genres/1
  def show
    render json: { data: lookup_json(@genre) }
  end

  # POST /genres
  def create
    @genre = Genre.new(genre_params)
    @genre.user = current_user

    if @genre.save
      render json: { data: lookup_json(@genre) }, status: :created, location: @genre
    else
      render json: @genre.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /genres/1
  def update
    return unless authorize_ownership!(@genre)

    if @genre.update(genre_params)
      render json: { data: lookup_json(@genre) }, status: :ok, location: @genre
    else
      render json: @genre.errors, status: :unprocessable_entity
    end
  end

  # DELETE /genres/1
  def destroy
    return unless authorize_ownership!(@genre)

    @genre.destroy!

    head :no_content
  end

  private

  def set_genre
    @genre = Genre.visible_to(current_user).find(params[:id])
  end

  def genre_params
    params.require(:genre).permit(:name)
  end
end
