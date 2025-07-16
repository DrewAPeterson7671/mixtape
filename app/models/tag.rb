class Tag < ApplicationRecord
    has_and_belongs_to_many :albums
    has_and_belongs_to_many :artists
    has_and_belongs_to_many :playlists
    has_and_belongs_to_many :tracks
end
