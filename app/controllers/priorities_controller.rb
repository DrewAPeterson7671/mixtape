class PrioritiesController < ApplicationController
  before_action :set_priority, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /priorities
  def index
    @priorities = Priority.all

    render json: { data: @priorities }
  end

  # GET /priorities/1
  def show
    render json: { data: @priority }
  end

  # POST /priorities
  def create
    @priority = Priority.new(priority_params)

    if @priority.save
      render json: { data: @priority }, status: :created, location: @priority
    else
      render json: @priority.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /priorities/1
  def update
    if @priority.update(priority_params)
      render json: { data: @priority }, status: :ok, location: @priority
    else
      render json: @priority.errors, status: :unprocessable_entity
    end
  end

  # DELETE /priorities/1
  def destroy
    @priority.destroy!

    head :no_content
  end

  private

  def set_priority
    @priority = Priority.find(params[:id])
  end

  def priority_params
    params.require(:priority).permit(:name)
  end
end
