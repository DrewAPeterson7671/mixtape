class CreateJoinTableArtistTrack < ActiveRecord::Migration[7.2]
  def change
    create_join_table :artists, :tracks do |t|
      t.index [ :artist_id, :track_id ], unique: true
      t.index [ :track_id, :artist_id ], unique: true
    end

    add_foreign_key :artists_tracks, :artists
    add_foreign_key :artists_tracks, :tracks
  end
end
