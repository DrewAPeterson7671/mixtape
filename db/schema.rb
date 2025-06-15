# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_06_15_170031) do
  create_table "albums", force: :cascade do |t|
    t.integer "artist"
    t.string "title"
    t.integer "year"
    t.boolean "listened"
    t.integer "release_type"
    t.integer "media"
    t.integer "edition"
    t.integer "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.integer "priority"
    t.integer "phase"
    t.boolean "complete"
    t.string "wikipedia"
    t.string "discogs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artists_genres", id: false, force: :cascade do |t|
    t.integer "artist_id", null: false
    t.integer "genre_id", null: false
    t.index ["artist_id", "genre_id"], name: "index_artists_genres_on_artist_id_and_genre_id", unique: true
    t.index ["genre_id", "artist_id"], name: "index_artists_genres_on_genre_id_and_artist_id", unique: true
  end

  create_table "artists_playlists", id: false, force: :cascade do |t|
    t.integer "playlist_id", null: false
    t.integer "artist_id", null: false
    t.index ["artist_id", "playlist_id"], name: "index_artists_playlists_on_artist_id_and_playlist_id", unique: true
    t.index ["playlist_id", "artist_id"], name: "index_artists_playlists_on_playlist_id_and_artist_id", unique: true
  end

  create_table "artists_tags", id: false, force: :cascade do |t|
    t.integer "artist_id", null: false
    t.integer "tag_id", null: false
    t.index ["artist_id", "tag_id"], name: "index_artists_tags_on_artist_id_and_tag_id", unique: true
    t.index ["tag_id", "artist_id"], name: "index_artists_tags_on_tag_id_and_artist_id", unique: true
  end

  create_table "editions", force: :cascade do |t|
    t.string "name"
    t.integer "album_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_editions_on_album_id"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name"
    t.integer "playlist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["playlist_id"], name: "index_genres_on_playlist_id"
  end

  create_table "media", force: :cascade do |t|
    t.string "name"
    t.integer "track_id"
    t.integer "album_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_media_on_album_id"
    t.index ["track_id"], name: "index_media_on_track_id"
  end

  create_table "phases", force: :cascade do |t|
    t.string "name"
    t.integer "artist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_phases_on_artist_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.integer "sequence"
    t.string "name"
    t.string "platform"
    t.text "comment"
    t.integer "genre"
    t.integer "year"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "playlists_tags", id: false, force: :cascade do |t|
    t.integer "playlist_id", null: false
    t.integer "tag_id", null: false
    t.index ["playlist_id", "tag_id"], name: "index_playlists_tags_on_playlist_id_and_tag_id", unique: true
    t.index ["tag_id", "playlist_id"], name: "index_playlists_tags_on_tag_id_and_playlist_id", unique: true
  end

  create_table "playlists_tracks", id: false, force: :cascade do |t|
    t.integer "playlist_id", null: false
    t.integer "track_id", null: false
    t.index ["playlist_id", "track_id"], name: "index_playlists_tracks_on_playlist_id_and_track_id", unique: true
    t.index ["track_id", "playlist_id"], name: "index_playlists_tracks_on_track_id_and_playlist_id", unique: true
  end

  create_table "priorities", force: :cascade do |t|
    t.string "name"
    t.integer "artist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_priorities_on_artist_id"
  end

  create_table "release_types", force: :cascade do |t|
    t.string "name"
    t.integer "album_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_release_types_on_album_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.integer "artist"
    t.integer "album"
    t.integer "track"
    t.integer "playlist"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags_tracks", id: false, force: :cascade do |t|
    t.integer "track_id", null: false
    t.integer "tag_id", null: false
    t.index ["tag_id", "track_id"], name: "index_tags_tracks_on_tag_id_and_track_id", unique: true
    t.index ["track_id", "tag_id"], name: "index_tags_tracks_on_track_id_and_tag_id", unique: true
  end

  create_table "tracks", force: :cascade do |t|
    t.integer "artist"
    t.integer "album"
    t.boolean "listened"
    t.string "title"
    t.integer "media"
    t.integer "number"
    t.integer "disc_number"
    t.integer "rating"
    t.integer "artist_id"
    t.integer "album_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_tracks_on_album_id"
    t.index ["artist_id"], name: "index_tracks_on_artist_id"
  end

  add_foreign_key "artists_genres", "artists"
  add_foreign_key "artists_genres", "genres"
  add_foreign_key "artists_playlists", "artists"
  add_foreign_key "artists_playlists", "playlists"
  add_foreign_key "artists_tags", "artists"
  add_foreign_key "artists_tags", "tags"
  add_foreign_key "playlists_tags", "playlists"
  add_foreign_key "playlists_tags", "tags"
  add_foreign_key "playlists_tracks", "playlists"
  add_foreign_key "playlists_tracks", "tracks"
  add_foreign_key "tags_tracks", "tags"
  add_foreign_key "tags_tracks", "tracks"
end
