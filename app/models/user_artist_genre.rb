class UserArtistGenre < ApplicationRecord
  belongs_to :user
  belongs_to :artist
  belongs_to :genre

  validates :genre_id, uniqueness: { scope: [ :user_id, :artist_id ] }
end
