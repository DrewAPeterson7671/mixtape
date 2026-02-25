class CreateUserArtists < ActiveRecord::Migration[7.2]
  def change
    create_table :user_artists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :artist, null: false, foreign_key: true
      t.integer :rating
      t.boolean :complete, default: false
      t.references :priority, foreign_key: true
      t.references :phase, foreign_key: true

      t.timestamps
    end

    add_index :user_artists, [:user_id, :artist_id], unique: true
  end
end
