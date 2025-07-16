json.extract! album, :id, :artist_id, :title, :year, :listened, :release_type_id, :media_id, :edition_id, :rating, :created_at, :updated_at
json.url album_url(album, format: :json)
