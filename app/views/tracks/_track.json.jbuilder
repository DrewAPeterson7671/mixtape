json.extract! track, :id, :artist, :album, :listened, :title, :media, :number, :disc_number, :rating, :created_at, :updated_at
json.url track_url(track, format: :json)
