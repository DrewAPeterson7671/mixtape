class CreateJoinTablePlaylistArtist < ActiveRecord::Migration[7.2]
  def change
    create_join_table :playlists, :artists do |t|
      t.index [:playlist_id, :artist_id], unique: true
      t.index [:artist_id, :playlist_id], unique: true
    end

    # Add foreign key constraints if necessary
    add_foreign_key :artists_playlists, :playlists
    add_foreign_key :artists_playlists, :artists
  end
end
