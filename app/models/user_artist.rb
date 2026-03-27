class UserArtist < ApplicationRecord
  belongs_to :user
  belongs_to :artist
  belongs_to :priority, optional: true
  belongs_to :phase, optional: true

  has_many :user_artist_genres, ->(ua) { where(user_id: ua.user_id) },
           foreign_key: :artist_id, primary_key: :artist_id, inverse_of: false, dependent: :destroy
  has_many :genres, through: :user_artist_genres

  has_many :user_artist_tags, ->(ua) { where(user_id: ua.user_id) },
           foreign_key: :artist_id, primary_key: :artist_id, inverse_of: false, dependent: :destroy
  has_many :tags, through: :user_artist_tags

  before_validation { self.rating = nil if rating_before_type_cast.to_s == "0" }

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
