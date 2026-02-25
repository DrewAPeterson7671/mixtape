class UserTrackTag < ApplicationRecord
  belongs_to :user
  belongs_to :track
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: [:user_id, :track_id] }
end
