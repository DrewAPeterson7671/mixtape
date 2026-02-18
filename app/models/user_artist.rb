class UserArtist < ApplicationRecord
  belongs_to :user
  belongs_to :artist
  belongs_to :priority, optional: true
  belongs_to :phase, optional: true

  has_many :user_artist_genres, dependent: :destroy
  has_many :genres, through: :user_artist_genres

  has_many :user_artist_tags, dependent: :destroy
  has_many :tags, through: :user_artist_tags

  validates :artist_id, uniqueness: { scope: :user_id }
  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true

  def genre_name
    genres.map(&:name)
  end

  def priority_name
    priority&.name
  end

  def phase_name
    phase&.name
  end
end
