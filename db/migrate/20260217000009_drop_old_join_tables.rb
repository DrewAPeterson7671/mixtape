class DropOldJoinTables < ActiveRecord::Migration[7.2]
  def up
    drop_table :artists_genres
    drop_table :artists_tags
    drop_table :albums_tags
    drop_table :tags_tracks
  end

  def down
    create_join_table :artists, :genres do |t|
      t.index [ :artist_id, :genre_id ], unique: true
      t.index [ :genre_id, :artist_id ], unique: true
    end
    add_foreign_key :artists_genres, :artists
    add_foreign_key :artists_genres, :genres

    create_join_table :artists, :tags do |t|
      t.index [ :artist_id, :tag_id ], unique: true
      t.index [ :tag_id, :artist_id ], unique: true
    end
    add_foreign_key :artists_tags, :artists
    add_foreign_key :artists_tags, :tags

    create_join_table :albums, :tags do |t|
      t.index [ :album_id, :tag_id ], unique: true
      t.index [ :tag_id, :album_id ], unique: true
    end
    add_foreign_key :albums_tags, :albums
    add_foreign_key :albums_tags, :tags

    create_join_table :tags, :tracks do |t|
      t.index [ :track_id, :tag_id ], unique: true
      t.index [ :tag_id, :track_id ], unique: true
    end
    add_foreign_key :tags_tracks, :tags
    add_foreign_key :tags_tracks, :tracks
  end
end
