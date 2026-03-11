class Album < ApplicationRecord
  has_and_belongs_to_many :artists
  has_many :album_tracks, dependent: :destroy
  has_many :tracks, through: :album_tracks
  belongs_to :medium, optional: true
  belongs_to :release_type, optional: true

  has_many :user_albums, dependent: :destroy
  has_many :users, through: :user_albums

  validates :title, presence: true

  validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 1500, less_than_or_equal_to: ->(_album) { Date.current.year } }, allow_nil: true

  def artist_name
    artists.map(&:name)
  end

  def release_type_name
    release_type&.name
  end

  def medium_name
    medium&.name
  end
end
