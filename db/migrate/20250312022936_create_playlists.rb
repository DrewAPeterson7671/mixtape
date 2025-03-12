class CreatePlaylists < ActiveRecord::Migration[7.2]
  def change
    create_table :playlists do |t|
      t.integer :sequence
      t.string :name
      t.string :platform
      t.text :comment
      t.integer :genre
      t.integer :year
      t.string :source

      t.timestamps
    end
  end
end
