class CreateAlbumTracks < ActiveRecord::Migration[7.2]
  def change
    create_table :album_tracks do |t|
      t.references :album, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true
      t.integer :position
      t.integer :disc_number
      t.timestamps
    end

    add_index :album_tracks, [:album_id, :track_id], unique: true
  end
end
