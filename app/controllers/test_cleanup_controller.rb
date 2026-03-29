class TestCleanupController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_login

  before_action :ensure_non_production

  # DELETE /test/cleanup
  #
  # Removes all catalog and settings records whose names start with "E2E " or
  # "E2F " — the prefixes used by the Playwright E2E specs.
  #
  # Order: tracks → albums → artists → settings, so dependent associations
  # (user prefs, HABTM join rows, album_tracks) are cleaned up by Rails
  # callbacks before we touch the records they reference.
  def destroy
    pattern = [ "E2E %", "E2F %" ]

    tracks  = Track.where("title LIKE ? OR title LIKE ?", *pattern)
    albums  = Album.where("title LIKE ? OR title LIKE ?", *pattern)
    artists = Artist.where("name LIKE ? OR name LIKE ?", *pattern)

    counts = {
      tracks:  tracks.count,
      albums:  albums.count,
      artists: artists.count
    }

    tracks.destroy_all
    albums.destroy_all
    artists.destroy_all

    { genres: Genre, tags: Tag, media: Medium, phases: Phase,
      priorities: Priority, release_types: ReleaseType }.each do |key, model|
      records = model.where("name LIKE ? OR name LIKE ?", *pattern)
      counts[key] = records.count
      records.destroy_all
    end

    render json: { deleted: counts }
  end

  private

  def ensure_non_production
    head :not_found unless Rails.env.development? || Rails.env.test?
  end
end
