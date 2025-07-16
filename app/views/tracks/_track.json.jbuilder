json.extract! track, :id, :artist_id, :album_id, :listened, :title, :media_id, :number, :disc_number, :rating, :created_at, :updated_at
json.url track_url(track, format: :json)
