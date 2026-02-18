class UserAlbumTag < ApplicationRecord
  belongs_to :user
  belongs_to :album
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: [:user_id, :album_id] }
end
