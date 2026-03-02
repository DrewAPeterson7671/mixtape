class AlbumTrack < ApplicationRecord
  belongs_to :album
  belongs_to :track

  validates :album_id, uniqueness: { scope: :track_id }
end
