class UserTrackGenre < ApplicationRecord
  belongs_to :user
  belongs_to :track
  belongs_to :genre

  validates :genre_id, uniqueness: { scope: [:user_id, :track_id] }
end
