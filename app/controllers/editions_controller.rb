class EditionsController < ApplicationController
  include LookupAuthorizable

  before_action :set_edition, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /editions
  def index
    @editions = Edition.visible_to(current_user).order(:name)

    render json: { data: lookup_collection_json(@editions) }
  end

  # GET /editions/1
  def show
    render json: { data: lookup_json(@edition) }
  end

  # POST /editions
  def create
    @edition = Edition.new(edition_params)
    @edition.user = current_user

    if @edition.save
      render json: { data: lookup_json(@edition) }, status: :created, location: @edition
    else
      render json: @edition.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /editions/1
  def update
    return unless authorize_ownership!(@edition)

    if @edition.update(edition_params)
      render json: { data: lookup_json(@edition) }, status: :ok, location: @edition
    else
      render json: @edition.errors, status: :unprocessable_entity
    end
  end

  # DELETE /editions/1
  def destroy
    return unless authorize_ownership!(@edition)

    @edition.destroy!

    head :no_content
  end

  private

  def set_edition
    @edition = Edition.visible_to(current_user).find(params[:id])
  end

  def edition_params
    params.require(:edition).permit(:name)
  end
end
