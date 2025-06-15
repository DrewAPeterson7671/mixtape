class CreateJoinTableArtistGenre < ActiveRecord::Migration[7.2]
  def change
      create_join_table :artists, :genres do |t|
      t.index [:artist_id, :genre_id], unique: true
      t.index [:genre_id, :artist_id], unique: true
    end

    # Add foreign key constraints if necessary
    add_foreign_key :artists_genres, :artists
    add_foreign_key :artists_genres, :genres
  end
end
