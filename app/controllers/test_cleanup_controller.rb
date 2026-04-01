class TestCleanupController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_login

  before_action :ensure_non_production

  def destroy
    deleted = {}
    started_after = params[:started_after].present? ? Time.zone.parse(params[:started_after]) : nil

    ActiveRecord::Base.transaction do
      e2e_user = User.find_by(email: "e2e@test.com")

      if e2e_user
        # Scope join records by started_after when provided
        user_artists = e2e_user.user_artists
        user_albums  = e2e_user.user_albums
        user_tracks  = e2e_user.user_tracks
        playlists    = e2e_user.playlists

        if started_after
          user_artists = user_artists.where("user_artists.created_at >= ?", started_after)
          user_albums  = user_albums.where("user_albums.created_at >= ?", started_after)
          user_tracks  = user_tracks.where("user_tracks.created_at >= ?", started_after)
          playlists    = playlists.where("playlists.created_at >= ?", started_after)
        end

        # Collect catalog IDs associated with the E2E user
        e2e_artist_ids = user_artists.pluck(:artist_id)
        e2e_album_ids  = user_albums.pluck(:album_id)
        e2e_track_ids  = user_tracks.pluck(:track_id)

        # Destroy user join records (cascades to sub-joins via dependent: :destroy)
        deleted[:user_artists] = user_artists.count
        user_artists.destroy_all

        deleted[:user_albums] = user_albums.count
        user_albums.destroy_all

        deleted[:user_tracks] = user_tracks.count
        user_tracks.destroy_all

        # Destroy E2E user's playlists
        deleted[:playlists] = playlists.count
        playlists.destroy_all

        # Delete orphaned catalog records (no remaining user associations)
        orphan_track_ids  = e2e_track_ids - UserTrack.where(track_id: e2e_track_ids).distinct.pluck(:track_id)
        orphan_album_ids  = e2e_album_ids - UserAlbum.where(album_id: e2e_album_ids).distinct.pluck(:album_id)
        orphan_artist_ids = e2e_artist_ids - UserArtist.where(artist_id: e2e_artist_ids).distinct.pluck(:artist_id)

        deleted[:tracks]  = orphan_track_ids.size
        Track.where(id: orphan_track_ids).destroy_all

        deleted[:albums]  = orphan_album_ids.size
        Album.where(id: orphan_album_ids).destroy_all

        deleted[:artists] = orphan_artist_ids.size
        Artist.where(id: orphan_artist_ids).destroy_all
      else
        deleted[:user_artists] = 0
        deleted[:user_albums]  = 0
        deleted[:user_tracks]  = 0
        deleted[:playlists]    = 0
        deleted[:tracks]       = 0
        deleted[:albums]       = 0
        deleted[:artists]      = 0
      end

      # Fallback: delete E2E-prefixed catalog records that have no user associations.
      # CRUD delete tests remove the join record during the test run, leaving behind
      # catalog records that the user-scoped cleanup above can't see.
      prefixes = [ "E2E %", "E2F %" ]

      stray_tracks = Track.where("title LIKE ? OR title LIKE ?", *prefixes)
        .where.not(id: UserTrack.select(:track_id))
      stray_tracks = stray_tracks.where("created_at >= ?", started_after) if started_after
      deleted[:tracks] = (deleted[:tracks] || 0) + stray_tracks.count
      stray_tracks.destroy_all

      stray_albums = Album.where("title LIKE ? OR title LIKE ?", *prefixes)
        .where.not(id: UserAlbum.select(:album_id))
      stray_albums = stray_albums.where("created_at >= ?", started_after) if started_after
      deleted[:albums] = (deleted[:albums] || 0) + stray_albums.count
      stray_albums.destroy_all

      stray_artists = Artist.where("name LIKE ? OR name LIKE ?", *prefixes)
        .where.not(id: UserArtist.select(:artist_id))
      stray_artists = stray_artists.where("created_at >= ?", started_after) if started_after
      deleted[:artists] = (deleted[:artists] || 0) + stray_artists.count
      stray_artists.destroy_all

      # Lookup records — prefix matching (no user association exists)
      { tags: Tag, genres: Genre, editions: Edition, media: Medium,
        phases: Phase, priorities: Priority, release_types: ReleaseType }.each do |key, model|
        records = model.where("name LIKE ? OR name LIKE ?", *prefixes)
        records = records.where("created_at >= ?", started_after) if started_after
        deleted[key] = records.count
        records.destroy_all
      end
    end

    render json: { deleted: deleted }
  end

  private

  def ensure_non_production
    head :not_found unless Rails.env.development? || Rails.env.test?
  end
end
