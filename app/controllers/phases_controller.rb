class PhasesController < ApplicationController
  before_action :set_phase, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /phases
  def index
    @phases = Phase.all

    render json: { data: @phases }
  end

  # GET /phases/1
  def show
    render json: { data: @phase }
  end

  # POST /phases
  def create
    @phase = Phase.new(phase_params)

    if @phase.save
      render json: { data: @phase }, status: :created, location: @phase
    else
      render json: @phase.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /phases/1
  def update
    if @phase.update(phase_params)
      render json: { data: @phase }, status: :ok, location: @phase
    else
      render json: @phase.errors, status: :unprocessable_entity
    end
  end

  # DELETE /phases/1
  def destroy
    @phase.destroy!

    head :no_content
  end

  private

  def set_phase
    @phase = Phase.find(params[:id])
  end

  def phase_params
    params.require(:phase).permit(:name)
  end
end
