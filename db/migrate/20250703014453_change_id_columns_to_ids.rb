class ChangeIdColumnsToIds < ActiveRecord::Migration[7.2]
  def change
    rename_column :albums, :release_type, :release_type_id
    rename_column :albums, :edition, :edition_id
    rename_column :albums, :media, :media_id
    rename_column :artists, :priority, :priority_id
    rename_column :artists, :phase, :phase_id
    rename_column :playlists, :genre, :genre_id
    rename_column :tracks, :media, :media_id
  end
end
