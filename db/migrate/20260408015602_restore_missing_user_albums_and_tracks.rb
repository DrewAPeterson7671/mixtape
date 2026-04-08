class RestoreMissingUserAlbumsAndTracks < ActiveRecord::Migration[7.2]
  def up
    # Restore missing UserAlbum records deleted by make_lookup_user_id_not_null migration
    execute <<~SQL.squish
      INSERT INTO user_albums (user_id, album_id, rating, listened, consider_editions, default_edition_id, created_at, updated_at)
      SELECT u.id, a.id, NULL, false, false, NULL, NOW(), NOW()
      FROM users u
      CROSS JOIN albums a
      WHERE NOT EXISTS (
        SELECT 1 FROM user_albums ua WHERE ua.user_id = u.id AND ua.album_id = a.id
      )
      ON CONFLICT (user_id, album_id) DO NOTHING
    SQL

    # Restore missing UserTrack records
    execute <<~SQL.squish
      INSERT INTO user_tracks (user_id, track_id, rating, listened, created_at, updated_at)
      SELECT u.id, t.id, NULL, false, NOW(), NOW()
      FROM users u
      CROSS JOIN tracks t
      WHERE NOT EXISTS (
        SELECT 1 FROM user_tracks ut WHERE ut.user_id = u.id AND ut.track_id = t.id
      )
      ON CONFLICT (user_id, track_id) DO NOTHING
    SQL
  end

  def down
    # No-op: can't distinguish restored records from legitimate ones
  end
end
