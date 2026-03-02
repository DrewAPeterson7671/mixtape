class MigrateTrackAlbumToAlbumTracks < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      INSERT INTO album_tracks (album_id, track_id, position, disc_number, created_at, updated_at)
      SELECT album_id, id, number, disc_number, NOW(), NOW()
      FROM tracks WHERE album_id IS NOT NULL
    SQL
  end

  def down
    execute <<-SQL
      UPDATE tracks SET
        album_id = at.album_id,
        number = at.position,
        disc_number = at.disc_number
      FROM album_tracks at WHERE at.track_id = tracks.id
    SQL
  end
end
