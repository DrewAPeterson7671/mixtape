class User < ApplicationRecord
  has_many :user_artists, dependent: :destroy
  has_many :user_albums, dependent: :destroy
  has_many :user_tracks, dependent: :destroy
  has_many :playlists, dependent: :destroy
  has_many :genres, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :editions, dependent: :destroy
  has_many :media, dependent: :destroy
  has_many :phases, dependent: :destroy
  has_many :priorities, dependent: :destroy
  has_many :release_types, dependent: :destroy
end
