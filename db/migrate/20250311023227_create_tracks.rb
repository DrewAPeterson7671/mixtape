class CreateTracks < ActiveRecord::Migration[7.2]
  def change
    create_table :tracks do |t|
      t.integer :artist
      t.integer :album
      t.boolean :listened
      t.string :title
      t.integer :media
      t.integer :number
      t.integer :disc_number
      t.integer :rating

      t.timestamps
    end
  end
end
