class UserTrack < ApplicationRecord
  belongs_to :user
  belongs_to :track

  has_many :user_track_genres, dependent: :destroy
  has_many :genres, through: :user_track_genres

  has_many :user_track_tags, dependent: :destroy
  has_many :tags, through: :user_track_tags

  validates :track_id, uniqueness: { scope: :user_id }
  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true
end
