class TagsController < ApplicationController
  before_action :set_tag, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /tags
  def index
    @tags = current_user.tags.order(:name)

    render json: { data: @tags }
  end

  # GET /tags/1
  def show
    render json: { data: @tag }
  end

  # POST /tags
  def create
    @tag = current_user.tags.build(tag_params)

    if @tag.save
      render json: { data: @tag }, status: :created, location: @tag
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tags/1
  def update
    if @tag.update(tag_params)
      render json: { data: @tag }, status: :ok, location: @tag
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tags/1
  def destroy
    @tag.destroy!

    head :no_content
  end

  private

  def set_tag
    @tag = current_user.tags.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name, :artist, :album, :track, :playlist, :comment)
  end
end
