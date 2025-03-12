json.extract! artist, :id, :name, :priority, :phase, :complete, :wikipedia, :discogs, :created_at, :updated_at
json.url artist_url(artist, format: :json)
