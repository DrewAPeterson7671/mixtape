class CreateAlbums < ActiveRecord::Migration[7.2]
  def change
    create_table :albums do |t|
      t.integer :artist
      t.string :title
      t.integer :year
      t.boolean :listened
      t.integer :release_type
      t.integer :media
      t.integer :edition
      t.integer :rating

      t.timestamps
    end
  end
end
