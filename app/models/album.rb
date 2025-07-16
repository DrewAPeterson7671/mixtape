class Album < ApplicationRecord
    has_and_belongs_to_many :artists
    has_and_belongs_to_many :tags
    has_many :media
    has_many :editions
    has_many :release_types
end
