class CreateJoinTableArtistAlbum < ActiveRecord::Migration[7.2]
  def change
    create_join_table :artists, :albums do |t|
      t.index [:artist_id, :album_id], unique: true
      t.index [:album_id, :artist_id], unique: true
    end

    # Add foreign key constraints if necessary
    add_foreign_key :artists_albums, :artists
    add_foreign_key :artists_albums, :albums
  end
end
