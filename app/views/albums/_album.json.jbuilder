json.extract! album, :id, :title, :year, :release_type_id, :medium_id, :edition_id, :created_at, :updated_at
json.url album_url(album, format: :json)
