class TracksController < ApplicationController
  include UserPreferable

  before_action :set_track, only: %i[show edit update destroy]
  skip_before_action :verify_authenticity_token

  # GET /tracks
  def index
    @tracks = Track.includes(:artist, :album, :medium).all
    @user_prefs = current_user.user_tracks
      .includes(:genres, :tags)
      .index_by(&:track_id)

    respond_to do |format|
      format.html
      format.json do
        render json: { data: @tracks.map { |track|
          pref = @user_prefs[track.id]
          track.as_json(
            only: [:id, :title, :number, :disc_number, :created_at, :updated_at],
            methods: [:artist_name, :album_title, :medium_name]
          ).merge(
            listened: pref&.listened || false,
            rating: pref&.rating
          )
        } }
      end
    end
  end

  # GET /tracks/1
  def show
    @user_pref = current_user_track(@track)

    respond_to do |format|
      format.html
      format.json do
        render json: { data: @track.as_json(
          only: [:id, :title, :number, :disc_number, :created_at, :updated_at],
          methods: [:artist_name, :album_title, :medium_name]
        ).merge(
          listened: @user_pref.listened || false,
          rating: @user_pref.rating
        ) }
      end
    end
  end

  # GET /tracks/new
  def new
    @track = Track.new
    @user_pref = UserTrack.new
  end

  # GET /tracks/1/edit
  def edit
    @user_pref = current_user_track(@track)
  end

  # POST /tracks
  def create
    ActiveRecord::Base.transaction do
      @track = Track.new(track_params)

      if @track.save
        @user_pref = current_user_track(@track)
        @user_pref.assign_attributes(preference_params)
        update_track_genres(@user_pref)
        update_track_tags(@user_pref)
        @user_pref.save!

        respond_to do |format|
          format.html { redirect_to @track, notice: "Track was successfully created." }
          format.json do
            render json: { data: @track.as_json(
              only: [:id, :title, :number, :disc_number, :created_at, :updated_at],
              methods: [:artist_name, :album_title, :medium_name]
            ).merge(
              listened: @user_pref.listened || false,
              rating: @user_pref.rating
            ) }, status: :created, location: @track
          end
        end
      else
        @user_pref = UserTrack.new(preference_params)
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @track.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /tracks/1
  def update
    ActiveRecord::Base.transaction do
      @track.assign_attributes(track_params)

      if @track.save
        @user_pref = current_user_track(@track)
        @user_pref.assign_attributes(preference_params)
        update_track_genres(@user_pref)
        update_track_tags(@user_pref)
        @user_pref.save!

        respond_to do |format|
          format.html { redirect_to @track, notice: "Track was successfully updated." }
          format.json do
            render json: { data: @track.as_json(
              only: [:id, :title, :number, :disc_number, :created_at, :updated_at],
              methods: [:artist_name, :album_title, :medium_name]
            ).merge(
              listened: @user_pref.listened || false,
              rating: @user_pref.rating
            ) }, status: :ok, location: @track
          end
        end
      else
        @user_pref = current_user_track(@track)
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @track.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /tracks/1
  def destroy
    current_user.user_tracks.where(track: @track).destroy_all

    respond_to do |format|
      format.html { redirect_to tracks_path, status: :see_other, notice: "Track preferences were removed." }
      format.json { head :no_content }
    end
  end

  private

  def set_track
    @track = Track.find(params[:id])
  end

  def track_params
    params.require(:track).permit(:title, :number, :disc_number, :medium_id, :artist_id, :album_id)
  end

  def preference_params
    params.require(:track).permit(:rating, :listened)
  end

  def update_track_genres(pref)
    return unless params[:track].key?(:genre_ids)

    genre_ids = Array(params[:track][:genre_ids]).map(&:to_i)
    pref.save! if pref.new_record?
    pref.user_track_genres.where.not(genre_id: genre_ids).destroy_all
    genre_ids.each do |gid|
      pref.user_track_genres.find_or_create_by!(user: current_user, track: pref.track, genre_id: gid)
    end
    pref.reload
  end

  def update_track_tags(pref)
    return unless params[:track].key?(:tag_ids)

    tag_ids = Array(params[:track][:tag_ids]).map(&:to_i)
    pref.save! if pref.new_record?
    pref.user_track_tags.where.not(tag_id: tag_ids).destroy_all
    tag_ids.each do |tid|
      pref.user_track_tags.find_or_create_by!(user: current_user, track: pref.track, tag_id: tid)
    end
    pref.reload
  end
end
