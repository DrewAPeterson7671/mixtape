class RenameMediaIdToMediumIdOnAlbums < ActiveRecord::Migration[7.2]
  def change
    rename_column :albums, :media_id, :medium_id
  end
end
