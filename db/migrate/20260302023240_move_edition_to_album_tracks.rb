class MoveEditionToAlbumTracks < ActiveRecord::Migration[7.2]
  def up
    add_reference :album_tracks, :edition, null: true, foreign_key: true

    execute <<~SQL
      UPDATE album_tracks
      SET edition_id = albums.edition_id
      FROM albums
      WHERE album_tracks.album_id = albums.id
    SQL

    remove_index :album_tracks, [:album_id, :track_id], unique: true
    add_index :album_tracks, [:album_id, :track_id, :edition_id],
              unique: true,
              name: "index_album_tracks_on_album_track_edition"

    remove_reference :albums, :edition
  end

  def down
    add_reference :albums, :edition, null: true

    execute <<~SQL
      UPDATE albums
      SET edition_id = album_tracks.edition_id
      FROM album_tracks
      WHERE albums.id = album_tracks.album_id
        AND album_tracks.edition_id IS NOT NULL
    SQL

    remove_index :album_tracks, name: "index_album_tracks_on_album_track_edition"
    add_index :album_tracks, [:album_id, :track_id], unique: true

    remove_reference :album_tracks, :edition, foreign_key: true
  end
end
