class RenameArtistWikipediaToWikipediaDiscography < ActiveRecord::Migration[7.2]
  def change
    rename_column :artists, :wikipedia, :wikipedia_discography
  end
end
