class CreateUserTagTables < ActiveRecord::Migration[7.2]
  def change
    create_table :user_artist_tags do |t|
      t.references :user, null: false, foreign_key: true
      t.references :artist, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_artist_tags, [ :user_id, :artist_id, :tag_id ], unique: true, name: 'idx_user_artist_tags_unique'

    create_table :user_album_tags do |t|
      t.references :user, null: false, foreign_key: true
      t.references :album, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_album_tags, [ :user_id, :album_id, :tag_id ], unique: true, name: 'idx_user_album_tags_unique'

    create_table :user_track_tags do |t|
      t.references :user, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_track_tags, [ :user_id, :track_id, :tag_id ], unique: true, name: 'idx_user_track_tags_unique'
  end
end
