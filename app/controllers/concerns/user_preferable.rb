module UserPreferable
  extend ActiveSupport::Concern

  private

  def current_user_artist(artist)
    current_user.user_artists.find_or_initialize_by(artist: artist)
  end

  def current_user_album(album)
    current_user.user_albums.find_or_initialize_by(album: album)
  end

  def current_user_track(track)
    current_user.user_tracks.find_or_initialize_by(track: track)
  end
end
