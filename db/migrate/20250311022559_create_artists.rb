class CreateArtists < ActiveRecord::Migration[7.2]
  def change
    create_table :artists do |t|
      t.string :name
      t.integer :priority
      t.integer :phase
      t.boolean :complete
      t.string :wikipedia
      t.string :discogs

      t.timestamps
    end
  end
end
