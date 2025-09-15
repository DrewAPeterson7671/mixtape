class SetDefaultListenedOnAlbums < ActiveRecord::Migration[7.2]
  def change
    change_column_default :albums, :listened, false
  end
end
