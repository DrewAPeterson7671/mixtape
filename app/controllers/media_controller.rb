class MediaController < ApplicationController
  before_action :set_medium, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /media
  def index
    @media = Medium.all

    render json: { data: @media }
  end

  # GET /media/1
  def show
    render json: { data: @medium }
  end

  # POST /media
  def create
    @medium = Medium.new(medium_params)

    if @medium.save
      render json: { data: @medium }, status: :created, location: @medium
    else
      render json: @medium.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /media/1
  def update
    if @medium.update(medium_params)
      render json: { data: @medium }, status: :ok, location: @medium
    else
      render json: @medium.errors, status: :unprocessable_entity
    end
  end

  # DELETE /media/1
  def destroy
    @medium.destroy!

    head :no_content
  end

  private

  def set_medium
    @medium = Medium.find(params[:id])
  end

  def medium_params
    params.require(:medium).permit(:name)
  end
end
