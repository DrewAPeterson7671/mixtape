class PrioritiesController < ApplicationController
  include LookupAuthorizable

  before_action :set_priority, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /priorities
  def index
    @priorities = Priority.visible_to(current_user).order(:name)

    render json: { data: lookup_collection_json(@priorities) }
  end

  # GET /priorities/1
  def show
    render json: { data: lookup_json(@priority) }
  end

  # POST /priorities
  def create
    @priority = Priority.new(priority_params)
    @priority.user = current_user

    if @priority.save
      render json: { data: lookup_json(@priority) }, status: :created, location: @priority
    else
      render json: @priority.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /priorities/1
  def update
    return unless authorize_ownership!(@priority)

    if @priority.update(priority_params)
      render json: { data: lookup_json(@priority) }, status: :ok, location: @priority
    else
      render json: @priority.errors, status: :unprocessable_entity
    end
  end

  # DELETE /priorities/1
  def destroy
    return unless authorize_ownership!(@priority)

    @priority.destroy!

    head :no_content
  end

  private

  def set_priority
    @priority = Priority.visible_to(current_user).find(params[:id])
  end

  def priority_params
    params.require(:priority).permit(:name)
  end
end
