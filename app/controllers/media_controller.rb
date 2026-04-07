class MediaController < ApplicationController
  include LookupAuthorizable

  before_action :set_medium, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /media
  def index
    @media = Medium.visible_to(current_user).order(:name)

    render json: { data: lookup_collection_json(@media) }
  end

  # GET /media/1
  def show
    render json: { data: lookup_json(@medium) }
  end

  # POST /media
  def create
    @medium = Medium.new(medium_params)
    @medium.user = current_user

    if @medium.save
      render json: { data: lookup_json(@medium) }, status: :created, location: @medium
    else
      render json: @medium.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /media/1
  def update
    return unless authorize_ownership!(@medium)

    if @medium.update(medium_params)
      render json: { data: lookup_json(@medium) }, status: :ok, location: @medium
    else
      render json: @medium.errors, status: :unprocessable_entity
    end
  end

  # DELETE /media/1
  def destroy
    return unless authorize_ownership!(@medium)

    @medium.destroy!

    head :no_content
  end

  private

  def set_medium
    @medium = Medium.visible_to(current_user).find(params[:id])
  end

  def medium_params
    params.require(:medium).permit(:name)
  end
end
