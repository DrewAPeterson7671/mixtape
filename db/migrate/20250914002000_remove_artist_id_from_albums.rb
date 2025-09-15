class RemoveArtistIdFromAlbums < ActiveRecord::Migration[7.2]
  def change
    remove_column :albums, :artist_id, :bigint
  end
end
