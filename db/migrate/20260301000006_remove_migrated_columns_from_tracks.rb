class RemoveMigratedColumnsFromTracks < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :tracks, :artists, if_exists: true
    remove_foreign_key :tracks, :albums, if_exists: true
    remove_column :tracks, :artist_id, :bigint
    remove_column :tracks, :album_id, :bigint
    remove_column :tracks, :number, :integer
    remove_column :tracks, :disc_number, :integer
  end
end
