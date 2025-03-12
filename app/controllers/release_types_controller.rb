class ReleaseTypesController < ApplicationController
  before_action :set_release_type, only: %i[ show edit update destroy ]

  # GET /release_types or /release_types.json
  def index
    @release_types = ReleaseType.all
  end

  # GET /release_types/1 or /release_types/1.json
  def show
  end

  # GET /release_types/new
  def new
    @release_type = ReleaseType.new
  end

  # GET /release_types/1/edit
  def edit
  end

  # POST /release_types or /release_types.json
  def create
    @release_type = ReleaseType.new(release_type_params)

    respond_to do |format|
      if @release_type.save
        format.html { redirect_to @release_type, notice: "Release type was successfully created." }
        format.json { render :show, status: :created, location: @release_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @release_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /release_types/1 or /release_types/1.json
  def update
    respond_to do |format|
      if @release_type.update(release_type_params)
        format.html { redirect_to @release_type, notice: "Release type was successfully updated." }
        format.json { render :show, status: :ok, location: @release_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @release_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /release_types/1 or /release_types/1.json
  def destroy
    @release_type.destroy!

    respond_to do |format|
      format.html { redirect_to release_types_path, status: :see_other, notice: "Release type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_release_type
      @release_type = ReleaseType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def release_type_params
      params.require(:release_type).permit(:name)
    end
end
