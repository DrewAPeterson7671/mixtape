class EditionsController < ApplicationController
  before_action :set_edition, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /editions
  def index
    @editions = Edition.all

    render json: { data: @editions }
  end

  # GET /editions/1
  def show
    render json: { data: @edition }
  end

  # POST /editions
  def create
    @edition = Edition.new(edition_params)

    if @edition.save
      render json: { data: @edition }, status: :created, location: @edition
    else
      render json: @edition.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /editions/1
  def update
    if @edition.update(edition_params)
      render json: { data: @edition }, status: :ok, location: @edition
    else
      render json: @edition.errors, status: :unprocessable_entity
    end
  end

  # DELETE /editions/1
  def destroy
    @edition.destroy!

    head :no_content
  end

  private

  def set_edition
    @edition = Edition.find(params[:id])
  end

  def edition_params
    params.require(:edition).permit(:name)
  end
end
