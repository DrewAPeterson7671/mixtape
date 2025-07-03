class ChangeAlbumArtistIdType < ActiveRecord::Migration[7.2]
  def change
    change_column(:albums, :artist_id, :bigint)
  end
end
