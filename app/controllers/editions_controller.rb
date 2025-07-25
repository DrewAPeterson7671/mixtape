class EditionsController < ApplicationController
  before_action :set_edition, only: %i[ show edit update destroy ]
  skip_before_action :verify_authenticity_token
  
  # GET /editions or /editions.json
  def index
    @editions = Edition.all
  end

  # GET /editions/1 or /editions/1.json
  def show
  end

  # GET /editions/new
  def new
    @edition = Edition.new
  end

  # GET /editions/1/edit
  def edit
  end

  # POST /editions or /editions.json
  def create
    @edition = Edition.new(edition_params)

    respond_to do |format|
      if @edition.save
        format.html { redirect_to @edition, notice: "Edition was successfully created." }
        format.json { render :show, status: :created, location: @edition }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @edition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /editions/1 or /editions/1.json
  def update
    respond_to do |format|
      if @edition.update(edition_params)
        format.html { redirect_to @edition, notice: "Edition was successfully updated." }
        format.json { render :show, status: :ok, location: @edition }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @edition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /editions/1 or /editions/1.json
  def destroy
    @edition.destroy!

    respond_to do |format|
      format.html { redirect_to editions_path, status: :see_other, notice: "Edition was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_edition
      @edition = Edition.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def edition_params
      params.require(:edition).permit(:name)
    end
end
