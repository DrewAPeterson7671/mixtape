class Track < ApplicationRecord
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :playlists
  has_many :album_tracks, dependent: :destroy
  has_many :albums, through: :album_tracks
  belongs_to :medium, optional: true

  has_many :user_tracks, dependent: :destroy
  has_many :users, through: :user_tracks

  validates :title, presence: true

  def artist_name
    artists.map(&:name)
  end

  def album_title
    albums.distinct.map(&:title)
  end

  def medium_name
    medium&.name
  end
end
