class AlbumsController < ApplicationController
  include UserPreferable

  before_action :set_album, only: %i[show update destroy edition_tracks]
  skip_before_action :verify_authenticity_token

  # GET /albums
  def index
    @albums = Album.includes(:artists, :medium, :release_type, album_tracks: { track: :artists, edition: {} }).all
    @user_prefs = current_user.user_albums
      .includes(:genres, :tags)
      .index_by(&:album_id)

    render json: { data: @albums.map { |album|
      album_json(album, @user_prefs[album.id], {})
    } }
  end

  # GET /albums/1
  def show
    @user_pref = current_user_album(@album)
    @user_track_prefs = current_user.user_tracks.where(track_id: @album.track_ids).index_by(&:track_id)

    render json: { data: album_json(@album, @user_pref, @user_track_prefs) }
  end

  # POST /albums
  def create
    ActiveRecord::Base.transaction do
      @album = Album.new(album_params)

      if @album.save
        @user_pref = current_user_album(@album)
        @user_pref.assign_attributes(preference_params)
        update_album_genres(@user_pref)
        update_album_tags(@user_pref)
        @user_pref.save!

        handle_album_tracks

        @user_track_prefs = current_user.user_tracks.where(track_id: @album.track_ids).index_by(&:track_id)
        render json: { data: album_json(@album, @user_pref, @user_track_prefs) }, status: :created, location: @album
      else
        render json: @album.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /albums/1
  def update
    ActiveRecord::Base.transaction do
      @album.assign_attributes(album_params)

      if @album.save
        @user_pref = current_user_album(@album)
        @user_pref.assign_attributes(preference_params)
        @user_pref.save!
        update_album_genres(@user_pref)
        update_album_tags(@user_pref)

        handle_album_tracks

        @user_track_prefs = current_user.user_tracks.where(track_id: @album.track_ids).index_by(&:track_id)
        render json: { data: album_json(@album, @user_pref, @user_track_prefs) }, status: :ok, location: @album
      else
        render json: @album.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /albums/1
  def destroy
    current_user.user_albums.where(album: @album).destroy_all

    head :no_content
  end

  # PUT /albums/:id/edition_tracks
  def edition_tracks
    edition_id = params[:edition_id].present? ? params[:edition_id].to_i : nil
    submitted = Array(params[:tracks])

    unless validate_disc_numbers(submitted)
      return render json: { error: "Disc numbers must be consecutive starting from 1 with no gaps" },
                    status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      existing = @album.album_tracks.where(edition_id: edition_id)
      existing_by_track_id = existing.index_by(&:track_id)
      submitted_track_ids = submitted.map { |t| t[:track_id].to_i }.to_set

      # Tracks in DB but not in submitted list → return to unsorted pool
      existing_by_track_id.each do |track_id, at|
        next if submitted_track_ids.include?(track_id)

        null_row = @album.album_tracks.find_by(track_id: track_id, edition_id: nil)
        if null_row
          at.destroy!
        else
          at.update!(edition_id: nil, position: nil, disc_number: nil)
        end
      end

      # Tracks in submitted list
      submitted.each do |t_params|
        track_id = t_params[:track_id].to_i
        position = t_params[:position].to_i
        disc_number = t_params[:disc_number].present? ? t_params[:disc_number].to_i : nil

        if existing_by_track_id.key?(track_id)
          # Update existing
          existing_by_track_id[track_id].update!(position: position, disc_number: disc_number)
        else
          # Find unsorted album_track for this track and reassign, or create new
          unsorted = @album.album_tracks.find_by(track_id: track_id, edition_id: nil)
          if unsorted
            unsorted.update!(edition_id: edition_id, position: position, disc_number: disc_number)
          else
            @album.album_tracks.create!(track_id: track_id, edition_id: edition_id, position: position, disc_number: disc_number)
          end
        end
      end
    end

    @album.reload
    @user_pref = current_user_album(@album)
    @user_track_prefs = current_user.user_tracks.where(track_id: @album.track_ids).index_by(&:track_id)

    render json: { data: album_json(@album, @user_pref, @user_track_prefs) }
  end

  private

  def set_album
    @album = Album.find(params[:id])
  end

  def validate_disc_numbers(submitted_tracks)
    disc_numbers = submitted_tracks.map { |t| t[:disc_number] }.compact.map(&:to_i)
    return true if disc_numbers.empty?

    sorted = disc_numbers.uniq.sort
    sorted == (1..sorted.length).to_a
  end

  def album_params
    params.require(:album).permit(:title, :year, :various_artists, :release_type_id, :medium_id, artist_ids: [])
  end

  def preference_params
    params.require(:album).permit(:rating, :listened, :consider_editions, :default_edition_id)
  end

  def handle_album_tracks
    return unless params[:album].key?(:album_tracks)

    submitted = Array(params[:album][:album_tracks])

    # Split into existing tracks (have track_id) and new inline tracks (have title, no track_id)
    existing_entries = []
    new_entries = []
    submitted.each do |at_params|
      if at_params[:track_id].present?
        existing_entries << at_params
      elsif at_params[:title].present?
        new_entries << at_params
      end
    end

    # Remove album_tracks not in the existing entries list
    keep_pairs = existing_entries.map { |at| [at[:track_id].to_i, at[:edition_id]&.to_i] }
    @album.album_tracks.each do |existing|
      pair = [existing.track_id, existing.edition_id]
      @album.album_tracks.destroy(existing) unless keep_pairs.include?(pair)
    end

    # Sync existing track entries
    existing_entries.each do |at_params|
      at = @album.album_tracks.find_or_initialize_by(
        track_id: at_params[:track_id].to_i,
        edition_id: at_params[:edition_id]&.to_i
      )
      at.position = at_params[:position]
      at.disc_number = at_params[:disc_number]
      at.save!
    end

    # Compute existing titles after syncing so we catch titles from linked tracks
    @album.reload
    existing_titles = @album.tracks.pluck(:title).to_set

    # Create new inline tracks
    new_entries.each do |at_params|
      track = create_inline_track(at_params, existing_titles)
      @album.album_tracks.create!(
        track: track,
        position: at_params[:position],
        disc_number: at_params[:disc_number],
        edition_id: at_params[:edition_id].present? ? at_params[:edition_id].to_i : nil
      )
    end

    @album.reload
  end

  def create_inline_track(at_params, existing_titles)
    title = resolve_duplicate_title(at_params[:title], existing_titles)
    track = Track.create!(
      title: title,
      duration: at_params[:duration].present? ? at_params[:duration].to_i : nil,
      isrc: at_params[:isrc]
    )

    # Artist assignment: per-track artist_ids for VA, otherwise inherit from album
    artist_ids = if at_params[:artist_ids].present?
                   Array(at_params[:artist_ids]).map(&:to_i)
    else
                   @album.artist_ids
    end
    track.artist_ids = artist_ids

    # Create UserTrack preference
    user_track = current_user.user_tracks.create!(
      track: track,
      listened: at_params[:listened].present? ? at_params[:listened] : false,
      rating: at_params[:rating].present? ? at_params[:rating].to_i : nil
    )

    copy_album_genres_to_track(user_track)

    track
  end

  def copy_album_genres_to_track(user_track)
    user_album = current_user.user_albums.find_by(album: @album)
    return unless user_album

    user_album.user_album_genres.each do |uag|
      UserTrackGenre.find_or_create_by!(
        user: current_user,
        track: user_track.track,
        genre: uag.genre
      )
    end
  end

  def resolve_duplicate_title(title, existing_titles)
    return title unless existing_titles.include?(title)

    counter = 1
    counter += 1 while existing_titles.include?("#{title} (#{counter})")
    resolved = "#{title} (#{counter})"
    existing_titles.add(resolved)
    resolved
  end

  def update_album_genres(pref)
    return unless params[:album].key?(:genre_ids)

    genre_ids = Array(params[:album][:genre_ids]).map(&:to_i)
    pref.save! if pref.new_record?
    pref.user_album_genres.where.not(genre_id: genre_ids).destroy_all
    genre_ids.each do |gid|
      pref.user_album_genres.find_or_create_by!(user: current_user, album: pref.album, genre_id: gid)
    end
    pref.reload
  end

  def update_album_tags(pref)
    return unless params[:album].key?(:tag_ids)

    tag_ids = Array(params[:album][:tag_ids]).map(&:to_i)
    pref.save! if pref.new_record?
    pref.user_album_tags.where.not(tag_id: tag_ids).destroy_all
    tag_ids.each do |tid|
      pref.user_album_tags.find_or_create_by!(user: current_user, album: pref.album, tag_id: tid)
    end
    pref.reload
  end

  def album_json(album, pref, user_track_prefs = {})
    album.as_json(
      only: [ :id, :title, :year, :various_artists, :created_at, :updated_at ],
      methods: [ :medium_name, :release_type_name ]
    ).merge(
      artist_name: album.various_artists? ? [ "Various Artists" ] : album.artist_name,
      listened: pref&.listened || false,
      consider_editions: pref&.consider_editions || false,
      default_edition_id: pref&.default_edition_id,
      rating: pref&.rating,
      release_type_id: album.release_type_id,
      medium_id: album.medium_id,
      artist_ids: album.artist_ids,
      genre_ids: pref&.genres&.map(&:id) || [],
      tag_ids: pref&.tags&.map(&:id) || [],
      genre_name: pref&.genre_name || [],
      tag_name: pref&.tags&.map(&:name) || [],
      album_tracks: album.album_tracks.sort_by { |at| [ at.disc_number || 0, at.position || 0 ] }.map { |at|
        user_track_pref = user_track_prefs[at.track_id]
        {
          track_id: at.track_id,
          track_title: at.track.title,
          artist_name: at.track.artists.map(&:name),
          artist_ids: at.track.artist_ids,
          position: at.position,
          disc_number: at.disc_number,
          duration: at.track.duration,
          isrc: at.track.isrc,
          edition_id: at.edition_id,
          edition_name: at.edition&.name,
          listened: user_track_pref&.listened || false,
          rating: user_track_pref&.rating
        }
      }
    )
  end
end
