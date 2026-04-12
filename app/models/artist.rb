class Artist < ApplicationRecord
  has_and_belongs_to_many :albums
  has_and_belongs_to_many :tracks
  has_and_belongs_to_many :playlists

  has_and_belongs_to_many :related_artists,
    class_name: "Artist",
    join_table: "related_artists",
    foreign_key: "artist_id",
    association_foreign_key: "related_artist_id"

  has_many :user_artists, dependent: :destroy
  has_many :users, through: :user_artists

  validates :name, uniqueness: { message: ": Artist %{value} already exists." }
end
