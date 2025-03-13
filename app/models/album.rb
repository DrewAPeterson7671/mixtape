class Album < ApplicationRecord
    belongs_to :artist
    belongs_to :album
    has_many :media
    has_many :editions
    has_many :release_types
end
