json.extract! track, :id, :title, :number, :disc_number, :medium_id, :artist_id, :album_id, :created_at, :updated_at
json.url track_url(track, format: :json)
