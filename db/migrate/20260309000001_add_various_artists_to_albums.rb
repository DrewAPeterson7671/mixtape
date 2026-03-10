class AddVariousArtistsToAlbums < ActiveRecord::Migration[7.2]
  def change
    add_column :albums, :various_artists, :boolean, default: false, null: false
  end
end
