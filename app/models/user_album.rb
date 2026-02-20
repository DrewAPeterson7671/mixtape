class UserAlbum < ApplicationRecord
  belongs_to :user
  belongs_to :album

  has_many :user_album_genres, ->(ua) { where(user_id: ua.user_id) },
           foreign_key: :album_id, inverse_of: false, dependent: :destroy
  has_many :genres, through: :user_album_genres

  has_many :user_album_tags, ->(ua) { where(user_id: ua.user_id) },
           foreign_key: :album_id, inverse_of: false, dependent: :destroy
  has_many :tags, through: :user_album_tags

  validates :album_id, uniqueness: { scope: :user_id }
  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true
end
