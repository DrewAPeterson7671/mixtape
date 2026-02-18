class UserAlbumGenre < ApplicationRecord
  belongs_to :user
  belongs_to :album
  belongs_to :genre

  validates :genre_id, uniqueness: { scope: [:user_id, :album_id] }
end
