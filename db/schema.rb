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

ActiveRecord::Schema[7.2].define(version: 2026_02_17_000009) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "albums", force: :cascade do |t|
    t.string "title"
    t.integer "year"
    t.bigint "release_type_id"
    t.bigint "medium_id"
    t.bigint "edition_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "albums_artists", id: false, force: :cascade do |t|
    t.bigint "artist_id", null: false
    t.bigint "album_id", null: false
    t.index ["album_id", "artist_id"], name: "index_albums_artists_on_album_id_and_artist_id", unique: true
    t.index ["artist_id", "album_id"], name: "index_albums_artists_on_artist_id_and_album_id", unique: true
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.string "wikipedia"
    t.string "discogs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artists_playlists", id: false, force: :cascade do |t|
    t.bigint "playlist_id", null: false
    t.bigint "artist_id", null: false
    t.index ["artist_id", "playlist_id"], name: "index_artists_playlists_on_artist_id_and_playlist_id", unique: true
    t.index ["playlist_id", "artist_id"], name: "index_artists_playlists_on_playlist_id_and_artist_id", unique: true
  end

  create_table "editions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genres", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "media", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "phases", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "playlists", force: :cascade do |t|
    t.integer "sequence"
    t.string "name"
    t.string "platform"
    t.text "comment"
    t.bigint "genre_id"
    t.integer "year"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_playlists_on_user_id"
  end

  create_table "playlists_tags", id: false, force: :cascade do |t|
    t.bigint "playlist_id", null: false
    t.bigint "tag_id", null: false
    t.index ["playlist_id", "tag_id"], name: "index_playlists_tags_on_playlist_id_and_tag_id", unique: true
    t.index ["tag_id", "playlist_id"], name: "index_playlists_tags_on_tag_id_and_playlist_id", unique: true
  end

  create_table "playlists_tracks", id: false, force: :cascade do |t|
    t.bigint "playlist_id", null: false
    t.bigint "track_id", null: false
    t.index ["playlist_id", "track_id"], name: "index_playlists_tracks_on_playlist_id_and_track_id", unique: true
    t.index ["track_id", "playlist_id"], name: "index_playlists_tracks_on_track_id_and_playlist_id", unique: true
  end

  create_table "priorities", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "release_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tracks", force: :cascade do |t|
    t.string "title"
    t.bigint "medium_id"
    t.integer "number"
    t.integer "disc_number"
    t.bigint "artist_id"
    t.bigint "album_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_tracks_on_album_id"
    t.index ["artist_id"], name: "index_tracks_on_artist_id"
  end

  create_table "user_album_genres", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "album_id", null: false
    t.bigint "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_user_album_genres_on_album_id"
    t.index ["genre_id"], name: "index_user_album_genres_on_genre_id"
    t.index ["user_id", "album_id", "genre_id"], name: "idx_user_album_genres_unique", unique: true
    t.index ["user_id"], name: "index_user_album_genres_on_user_id"
  end

  create_table "user_album_tags", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "album_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_user_album_tags_on_album_id"
    t.index ["tag_id"], name: "index_user_album_tags_on_tag_id"
    t.index ["user_id", "album_id", "tag_id"], name: "idx_user_album_tags_unique", unique: true
    t.index ["user_id"], name: "index_user_album_tags_on_user_id"
  end

  create_table "user_albums", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "album_id", null: false
    t.integer "rating"
    t.boolean "listened", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_user_albums_on_album_id"
    t.index ["user_id", "album_id"], name: "index_user_albums_on_user_id_and_album_id", unique: true
    t.index ["user_id"], name: "index_user_albums_on_user_id"
  end

  create_table "user_artist_genres", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "artist_id", null: false
    t.bigint "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_user_artist_genres_on_artist_id"
    t.index ["genre_id"], name: "index_user_artist_genres_on_genre_id"
    t.index ["user_id", "artist_id", "genre_id"], name: "idx_user_artist_genres_unique", unique: true
    t.index ["user_id"], name: "index_user_artist_genres_on_user_id"
  end

  create_table "user_artist_tags", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "artist_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_user_artist_tags_on_artist_id"
    t.index ["tag_id"], name: "index_user_artist_tags_on_tag_id"
    t.index ["user_id", "artist_id", "tag_id"], name: "idx_user_artist_tags_unique", unique: true
    t.index ["user_id"], name: "index_user_artist_tags_on_user_id"
  end

  create_table "user_artists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "artist_id", null: false
    t.integer "rating"
    t.boolean "complete", default: false
    t.bigint "priority_id"
    t.bigint "phase_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_user_artists_on_artist_id"
    t.index ["phase_id"], name: "index_user_artists_on_phase_id"
    t.index ["priority_id"], name: "index_user_artists_on_priority_id"
    t.index ["user_id", "artist_id"], name: "index_user_artists_on_user_id_and_artist_id", unique: true
    t.index ["user_id"], name: "index_user_artists_on_user_id"
  end

  create_table "user_track_genres", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.bigint "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "index_user_track_genres_on_genre_id"
    t.index ["track_id"], name: "index_user_track_genres_on_track_id"
    t.index ["user_id", "track_id", "genre_id"], name: "idx_user_track_genres_unique", unique: true
    t.index ["user_id"], name: "index_user_track_genres_on_user_id"
  end

  create_table "user_track_tags", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_user_track_tags_on_tag_id"
    t.index ["track_id"], name: "index_user_track_tags_on_track_id"
    t.index ["user_id", "track_id", "tag_id"], name: "idx_user_track_tags_unique", unique: true
    t.index ["user_id"], name: "index_user_track_tags_on_user_id"
  end

  create_table "user_tracks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.integer "rating"
    t.boolean "listened", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_id"], name: "index_user_tracks_on_track_id"
    t.index ["user_id", "track_id"], name: "index_user_tracks_on_user_id_and_track_id", unique: true
    t.index ["user_id"], name: "index_user_tracks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cognito_sub", null: false
    t.index ["cognito_sub"], name: "index_users_on_cognito_sub", unique: true
  end

  add_foreign_key "albums_artists", "albums"
  add_foreign_key "albums_artists", "artists"
  add_foreign_key "artists_playlists", "artists"
  add_foreign_key "artists_playlists", "playlists"
  add_foreign_key "playlists", "users"
  add_foreign_key "playlists_tags", "playlists"
  add_foreign_key "playlists_tags", "tags"
  add_foreign_key "playlists_tracks", "playlists"
  add_foreign_key "playlists_tracks", "tracks"
  add_foreign_key "user_album_genres", "albums"
  add_foreign_key "user_album_genres", "genres"
  add_foreign_key "user_album_genres", "users"
  add_foreign_key "user_album_tags", "albums"
  add_foreign_key "user_album_tags", "tags"
  add_foreign_key "user_album_tags", "users"
  add_foreign_key "user_albums", "albums"
  add_foreign_key "user_albums", "users"
  add_foreign_key "user_artist_genres", "artists"
  add_foreign_key "user_artist_genres", "genres"
  add_foreign_key "user_artist_genres", "users"
  add_foreign_key "user_artist_tags", "artists"
  add_foreign_key "user_artist_tags", "tags"
  add_foreign_key "user_artist_tags", "users"
  add_foreign_key "user_artists", "artists"
  add_foreign_key "user_artists", "phases"
  add_foreign_key "user_artists", "priorities"
  add_foreign_key "user_artists", "users"
  add_foreign_key "user_track_genres", "genres"
  add_foreign_key "user_track_genres", "tracks"
  add_foreign_key "user_track_genres", "users"
  add_foreign_key "user_track_tags", "tags"
  add_foreign_key "user_track_tags", "tracks"
  add_foreign_key "user_track_tags", "users"
  add_foreign_key "user_tracks", "tracks"
  add_foreign_key "user_tracks", "users"
end
