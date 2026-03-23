class Playlist < ApplicationRecord
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :tracks
  has_and_belongs_to_many :tags
  belongs_to :genre
  belongs_to :user

  validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 1500, less_than_or_equal_to: ->(_album) { Date.current.year } }, allow_nil: true

  validates :name, presence: true, uniqueness: { scope: :user_id, message: ": Playlist %{value} already exists." }

  validates :platform, presence: true

  def genre_name
    genre&.name
  end
end
