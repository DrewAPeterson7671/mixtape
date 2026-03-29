class UserTrack < ApplicationRecord
  belongs_to :user
  belongs_to :track

  has_many :user_track_genres, ->(ut) { where(user_id: ut.user_id) },
           foreign_key: :track_id, primary_key: :track_id, inverse_of: false, dependent: :destroy
  has_many :genres, through: :user_track_genres

  has_many :user_track_tags, ->(ut) { where(user_id: ut.user_id) },
           foreign_key: :track_id, primary_key: :track_id, inverse_of: false, dependent: :destroy
  has_many :tags, through: :user_track_tags

  before_validation { self.rating = nil if rating_before_type_cast.to_s == "0" }

  validates :track_id, uniqueness: { scope: :user_id }
  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true

  def genre_name
    genres.map(&:name)
  end
end
