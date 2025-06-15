class CreateJoinTableTrackPlaylist < ActiveRecord::Migration[7.2]
  def change
    create_join_table :playlists, :tracks do |t|
      t.index [:playlist_id, :track_id], unique: true
      t.index [:track_id, :playlist_id], unique: true
    end

    # Add foreign key constraints if necessary
    add_foreign_key :playlists_tracks, :playlists
    add_foreign_key :playlists_tracks, :tracks
  end
end
