class RemoveForeignKeysFromTags < ActiveRecord::Migration[7.0]
  def change
    remove_column :tags, :artist_id, :integer
    remove_column :tags, :album_id, :integer
    remove_column :tags, :track_id, :integer
    remove_column :tags, :playlist_id, :integer
  end
end
