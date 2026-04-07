class TagsController < ApplicationController
  include LookupAuthorizable

  before_action :set_tag, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token

  # GET /tags
  def index
    @tags = Tag.visible_to(current_user).order(:name)

    render json: { data: lookup_collection_json(@tags) }
  end

  # GET /tags/1
  def show
    render json: { data: lookup_json(@tag) }
  end

  # POST /tags
  def create
    @tag = Tag.new(tag_params)
    @tag.user = current_user

    if @tag.save
      render json: { data: lookup_json(@tag) }, status: :created, location: @tag
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tags/1
  def update
    return unless authorize_ownership!(@tag)

    if @tag.update(tag_params)
      render json: { data: lookup_json(@tag) }, status: :ok, location: @tag
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tags/1
  def destroy
    return unless authorize_ownership!(@tag)

    @tag.destroy!

    head :no_content
  end

  private

  def set_tag
    @tag = Tag.visible_to(current_user).find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name, :artist, :album, :track, :playlist, :comment)
  end
end
