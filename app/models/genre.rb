class Genre < ApplicationRecord
  has_many :user_artist_genres, dependent: :destroy
  has_many :user_album_genres, dependent: :destroy
  has_many :user_track_genres, dependent: :destroy
end
