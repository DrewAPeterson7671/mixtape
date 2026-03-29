class ReleaseTypesController < ApplicationController
  before_action :set_release_type, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /release_types
  def index
    @release_types = ReleaseType.all.order(:name)

    render json: { data: @release_types }
  end

  # GET /release_types/1
  def show
    render json: { data: @release_type }
  end

  # POST /release_types
  def create
    @release_type = ReleaseType.new(release_type_params)

    if @release_type.save
      render json: { data: @release_type }, status: :created, location: @release_type
    else
      render json: @release_type.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /release_types/1
  def update
    if @release_type.update(release_type_params)
      render json: { data: @release_type }, status: :ok, location: @release_type
    else
      render json: @release_type.errors, status: :unprocessable_entity
    end
  end

  # DELETE /release_types/1
  def destroy
    @release_type.destroy!

    head :no_content
  end

  private

  def set_release_type
    @release_type = ReleaseType.find(params[:id])
  end

  def release_type_params
    params.require(:release_type).permit(:name)
  end
end
