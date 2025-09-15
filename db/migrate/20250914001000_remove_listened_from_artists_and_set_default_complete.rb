class RemoveListenedFromArtistsAndSetDefaultComplete < ActiveRecord::Migration[7.2]
  def change
    remove_column :artists, :listened, :boolean
    change_column_default :artists, :complete, false
  end
end
