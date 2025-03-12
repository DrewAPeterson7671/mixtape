json.extract! playlist, :id, :sequence, :name, :platform, :comment, :genre, :year, :source, :created_at, :updated_at
json.url playlist_url(playlist, format: :json)
