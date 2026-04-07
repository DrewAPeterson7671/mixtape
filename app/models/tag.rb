class Tag < ApplicationRecord
  include UserOwnable

  has_and_belongs_to_many :playlists

  has_many :user_artist_tags, dependent: :destroy
  has_many :user_album_tags, dependent: :destroy
  has_many :user_track_tags, dependent: :destroy
end
