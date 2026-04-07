class PhasesController < ApplicationController
  include LookupAuthorizable

  before_action :set_phase, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /phases
  def index
    @phases = Phase.visible_to(current_user).order(:name)

    render json: { data: lookup_collection_json(@phases) }
  end

  # GET /phases/1
  def show
    render json: { data: lookup_json(@phase) }
  end

  # POST /phases
  def create
    @phase = Phase.new(phase_params)
    @phase.user = current_user

    if @phase.save
      render json: { data: lookup_json(@phase) }, status: :created, location: @phase
    else
      render json: @phase.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /phases/1
  def update
    return unless authorize_ownership!(@phase)

    if @phase.update(phase_params)
      render json: { data: lookup_json(@phase) }, status: :ok, location: @phase
    else
      render json: @phase.errors, status: :unprocessable_entity
    end
  end

  # DELETE /phases/1
  def destroy
    return unless authorize_ownership!(@phase)

    @phase.destroy!

    head :no_content
  end

  private

  def set_phase
    @phase = Phase.visible_to(current_user).find(params[:id])
  end

  def phase_params
    params.require(:phase).permit(:name)
  end
end
