class Artist < ApplicationRecord
  has_and_belongs_to_many :albums
  has_and_belongs_to_many :tracks
  has_and_belongs_to_many :playlists

  has_many :user_artists, dependent: :destroy
  has_many :users, through: :user_artists

  validates :name, uniqueness: { message: ": Artist %{value} already exists." }
end
