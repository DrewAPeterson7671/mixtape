class Artist < ApplicationRecord
    has_many :artists
    has_many :albums
    has_many :priorities
    has_many :phases
end
