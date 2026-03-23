class AlbumTrack < ApplicationRecord
  belongs_to :album
  belongs_to :track
  belongs_to :edition, optional: true

  validates :album_id, uniqueness: { scope: [ :track_id, :edition_id ] }
end
