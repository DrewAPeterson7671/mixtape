class CreateUserGenreTables < ActiveRecord::Migration[7.2]
  def change
    create_table :user_artist_genres do |t|
      t.references :user, null: false, foreign_key: true
      t.references :artist, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_artist_genres, [:user_id, :artist_id, :genre_id], unique: true, name: 'idx_user_artist_genres_unique'

    create_table :user_album_genres do |t|
      t.references :user, null: false, foreign_key: true
      t.references :album, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_album_genres, [:user_id, :album_id, :genre_id], unique: true, name: 'idx_user_album_genres_unique'

    create_table :user_track_genres do |t|
      t.references :user, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_track_genres, [:user_id, :track_id, :genre_id], unique: true, name: 'idx_user_track_genres_unique'
  end
end
