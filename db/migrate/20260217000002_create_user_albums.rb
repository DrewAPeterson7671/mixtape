class CreateUserAlbums < ActiveRecord::Migration[7.2]
  def change
    create_table :user_albums do |t|
      t.references :user, null: false, foreign_key: true
      t.references :album, null: false, foreign_key: true
      t.integer :rating
      t.boolean :listened, default: false

      t.timestamps
    end

    add_index :user_albums, [:user_id, :album_id], unique: true
  end
end
