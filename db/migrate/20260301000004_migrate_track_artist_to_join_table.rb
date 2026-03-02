class MigrateTrackArtistToJoinTable < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      INSERT INTO artists_tracks (artist_id, track_id)
      SELECT artist_id, id FROM tracks WHERE artist_id IS NOT NULL
    SQL
  end

  def down
    execute <<-SQL
      UPDATE tracks SET artist_id = (
        SELECT artist_id FROM artists_tracks WHERE track_id = tracks.id LIMIT 1
      )
    SQL
  end
end
