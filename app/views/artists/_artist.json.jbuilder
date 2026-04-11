json.extract! artist, :id, :name, :wikipedia_discography, :discogs,
  :notes, :wikipedia, :official_page, :bandcamp, :last_fm,
  :google_genre_link, :all_music, :all_music_discography,
  :created_at, :updated_at
json.related_artist_ids artist.related_artist_ids
json.url artist_url(artist, format: :json)
