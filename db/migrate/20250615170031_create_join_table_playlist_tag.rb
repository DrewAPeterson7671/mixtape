class CreateJoinTablePlaylistTag < ActiveRecord::Migration[7.2]
  def change
      create_join_table :playlists, :tags do |t|
      t.index [:playlist_id, :tag_id], unique: true
      t.index [:tag_id, :playlist_id], unique: true
    end

    # Add foreign key constraints if necessary
    add_foreign_key :playlists_tags, :playlists
    add_foreign_key :playlists_tags, :tags
  end
end
