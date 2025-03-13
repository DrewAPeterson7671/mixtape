class CreateTags < ActiveRecord::Migration[7.2]
  def change
    create_table :tags do |t|
      t.string :name
      t.integer :artist
      t.integer :album
      t.integer :track
      t.integer :playlist
      t.text :comment
      
      t.timestamps
    end
  end
end
