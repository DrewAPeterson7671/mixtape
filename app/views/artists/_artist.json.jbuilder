json.extract! artist, :id, :name, :priority_id, :phase_id, :complete, :wikipedia, :discogs, :created_at, :updated_at
json.url artist_url(artist, format: :json)
