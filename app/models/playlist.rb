class Playlist < ApplicationRecord
    has_and_belongs_to_many :artists
    has_and_belongs_to_many :tracks
    has_and_belongs_to_many :tags
    has_many :genres
end
