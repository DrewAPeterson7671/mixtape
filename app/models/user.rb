class User < ApplicationRecord
  has_many :user_artists, dependent: :destroy
  has_many :user_albums, dependent: :destroy
  has_many :user_tracks, dependent: :destroy
  has_many :playlists, dependent: :destroy
end
