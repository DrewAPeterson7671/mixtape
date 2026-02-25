namespace :data do
  desc 'Migrate existing preference data to per-user tables (assigns to User.first)'
  task migrate_to_user_preferences: :environment do
    user = User.first
    abort 'No users found. Create a user first.' unless user

    ActiveRecord::Base.transaction do
      # 1. Artists -> UserArtists
      artist_count = 0
      Artist.find_each do |artist|
        UserArtist.create!(
          user: user,
          artist: artist,
          complete: artist.complete,
          priority_id: artist.priority_id,
          phase_id: artist.phase_id
        )
        artist_count += 1
      end
      puts "Migrated #{artist_count} artists to user_artists"

      # 2. Albums -> UserAlbums
      album_count = 0
      Album.find_each do |album|
        UserAlbum.create!(
          user: user,
          album: album,
          rating: album.rating,
          listened: album.listened
        )
        album_count += 1
      end
      puts "Migrated #{album_count} albums to user_albums"

      # 3. Tracks -> UserTracks
      track_count = 0
      Track.find_each do |track|
        UserTrack.create!(
          user: user,
          track: track,
          rating: track.rating,
          listened: track.listened
        )
        track_count += 1
      end
      puts "Migrated #{track_count} tracks to user_tracks"

      # 4. artists_genres -> user_artist_genres
      genre_count = 0
      ActiveRecord::Base.connection.execute('SELECT artist_id, genre_id FROM artists_genres').each do |row|
        UserArtistGenre.create!(
          user: user,
          artist_id: row['artist_id'],
          genre_id: row['genre_id']
        )
        genre_count += 1
      end
      puts "Migrated #{genre_count} artist-genre associations to user_artist_genres"

      # 5. artists_tags -> user_artist_tags
      artist_tag_count = 0
      ActiveRecord::Base.connection.execute('SELECT artist_id, tag_id FROM artists_tags').each do |row|
        UserArtistTag.create!(
          user: user,
          artist_id: row['artist_id'],
          tag_id: row['tag_id']
        )
        artist_tag_count += 1
      end
      puts "Migrated #{artist_tag_count} artist-tag associations to user_artist_tags"

      # 6. albums_tags -> user_album_tags
      album_tag_count = 0
      ActiveRecord::Base.connection.execute('SELECT album_id, tag_id FROM albums_tags').each do |row|
        UserAlbumTag.create!(
          user: user,
          album_id: row['album_id'],
          tag_id: row['tag_id']
        )
        album_tag_count += 1
      end
      puts "Migrated #{album_tag_count} album-tag associations to user_album_tags"

      # 7. tags_tracks -> user_track_tags
      track_tag_count = 0
      ActiveRecord::Base.connection.execute('SELECT track_id, tag_id FROM tags_tracks').each do |row|
        UserTrackTag.create!(
          user: user,
          track_id: row['track_id'],
          tag_id: row['tag_id']
        )
        track_tag_count += 1
      end
      puts "Migrated #{track_tag_count} track-tag associations to user_track_tags"

      # 8. Set user_id on all existing playlists
      playlist_count = Playlist.where(user_id: nil).update_all(user_id: user.id)
      puts "Assigned #{playlist_count} playlists to user #{user.id}"
    end

    puts 'Data migration complete!'
  end
end
