json.extract! artist, :id, :name, :wikipedia_discography, :discogs, :created_at, :updated_at
json.url artist_url(artist, format: :json)
