class EpochsController < ApplicationController
  before_action :set_epoch, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /epochs
  def index
    @epochs = current_user.epochs.order(Arel.sql('sequence ASC NULLS LAST, name ASC'))

    render json: { data: @epochs }
  end

  # GET /epochs/1
  def show
    render json: { data: @epoch }
  end

  # POST /epochs
  def create
    @epoch = current_user.epochs.build(epoch_params)

    if @epoch.save
      render json: { data: @epoch }, status: :created, location: @epoch
    else
      render json: @epoch.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /epochs/1
  def update
    if @epoch.update(epoch_params)
      render json: { data: @epoch }, status: :ok, location: @epoch
    else
      render json: @epoch.errors, status: :unprocessable_entity
    end
  end

  # DELETE /epochs/1
  def destroy
    @epoch.destroy!

    head :no_content
  end

  private

  def set_epoch
    @epoch = current_user.epochs.find(params[:id])
  end

  def epoch_params
    params.require(:epoch).permit(:name, :sequence, :definition, :year_start, :year_end, :replay, :weight)
  end
end
