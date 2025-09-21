class Artist < ApplicationRecord
    has_and_belongs_to_many :albums
    has_and_belongs_to_many :genres
    has_and_belongs_to_many :playlists
    has_and_belongs_to_many :tags
    belongs_to :priority, optional: true
    belongs_to :phase, optional: true

    validates :name, uniqueness: { message: ': Artist %{value} already exists.' }

    def genre_name
        genres.map(&:name)
    end

    def priority_name
        priority&.name
    end

    def phase_name
        phase&.name
    end
    
end
