class RenameMediaIdToMediumIdInTracks < ActiveRecord::Migration[7.0]
  def change
    rename_column :tracks, :media_id, :medium_id
  end
end
