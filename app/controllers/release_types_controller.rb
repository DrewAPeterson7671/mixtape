class ReleaseTypesController < ApplicationController
  include LookupAuthorizable

  before_action :set_release_type, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /release_types
  def index
    @release_types = ReleaseType.visible_to(current_user).order(:name)

    render json: { data: lookup_collection_json(@release_types) }
  end

  # GET /release_types/1
  def show
    render json: { data: lookup_json(@release_type) }
  end

  # POST /release_types
  def create
    @release_type = ReleaseType.new(release_type_params)
    @release_type.user = current_user

    if @release_type.save
      render json: { data: lookup_json(@release_type) }, status: :created, location: @release_type
    else
      render json: @release_type.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /release_types/1
  def update
    return unless authorize_ownership!(@release_type)

    if @release_type.update(release_type_params)
      render json: { data: lookup_json(@release_type) }, status: :ok, location: @release_type
    else
      render json: @release_type.errors, status: :unprocessable_entity
    end
  end

  # DELETE /release_types/1
  def destroy
    return unless authorize_ownership!(@release_type)

    @release_type.destroy!

    head :no_content
  end

  private

  def set_release_type
    @release_type = ReleaseType.visible_to(current_user).find(params[:id])
  end

  def release_type_params
    params.require(:release_type).permit(:name)
  end
end
