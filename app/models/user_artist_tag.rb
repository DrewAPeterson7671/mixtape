class UserArtistTag < ApplicationRecord
  belongs_to :user
  belongs_to :artist
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: [ :user_id, :artist_id ] }
end
