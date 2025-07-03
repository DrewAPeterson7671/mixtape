class RemoveExtraColumns < ActiveRecord::Migration[7.2]
  def change
    remove_column :tracks, :artist
    remove_column :tracks, :album
    remove_index :release_types, :album_id
    remove_column :release_types, :album_id
    remove_index :priorities, :artist_id
    remove_column :priorities, :artist_id
    remove_index :phases, :artist_id
    remove_column :phases, :artist_id
    remove_index :media, :track_id
    remove_index :media, :album_id
    remove_column :media, :track_id
    remove_column :media, :album_id
    remove_index :genres, :playlist_id
    remove_column :genres, :playlist_id
    remove_index :editions, :album_id
    remove_column :editions, :album_id
  end
end
