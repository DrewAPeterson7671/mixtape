class Artist < ApplicationRecord
    has_and_belongs_to_many :albums
    has_and_belongs_to_many :genres
    has_and_belongs_to_many :playlists
    has_and_belongs_to_many :tags
    has_many :priorities
    has_many :phases

    validates :name, uniqueness: { message: ': Artist %{value} already exists.' }

    
end
