class AddNotesAndWikipediaToAlbums < ActiveRecord::Migration[7.2]
  def change
    add_column :albums, :notes, :text
    add_column :albums, :wikipedia, :text
  end
end
