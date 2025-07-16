class ChangeTagsColumnsToAddId < ActiveRecord::Migration[7.2]
  def change
    rename_column :tags, :artist, :artist_id
    rename_column :tags, :album, :album_id
    rename_column :tags, :track, :track_id
    rename_column :tags, :playlist, :playlist_id
    change_column(:tags, :artist_id, :bigint)
    change_column(:tags, :album_id, :bigint)
    change_column(:tags, :track_id, :bigint)
    change_column(:tags, :playlist_id, :bigint)
  end
end
