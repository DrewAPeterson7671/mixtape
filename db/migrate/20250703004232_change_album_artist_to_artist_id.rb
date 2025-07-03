class ChangeAlbumArtistToArtistId < ActiveRecord::Migration[7.2]
  def change
    rename_column :albums, :artist, :artist_id
  end
end
