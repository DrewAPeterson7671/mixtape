class Track < ApplicationRecord
  has_and_belongs_to_many :playlists
  belongs_to :medium, optional: true
  belongs_to :album, optional: true
  belongs_to :artist

  has_many :user_tracks, dependent: :destroy
  has_many :users, through: :user_tracks

  validates :title, presence: true
  validates :artist, presence: true

  def artist_name
    artist&.name
  end

  def album_title
    album&.title
  end

  def medium_name
    medium&.name
  end
end
