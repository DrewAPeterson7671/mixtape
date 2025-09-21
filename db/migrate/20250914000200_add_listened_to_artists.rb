class AddListenedToArtists < ActiveRecord::Migration[7.2]
  def change
    add_column :artists, :listened, :boolean, default: false
  end
end
