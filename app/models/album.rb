class Album < ApplicationRecord
    has_and_belongs_to_many :artists
    has_and_belongs_to_many :tags
    belongs_to :medium, optional: true
    belongs_to :edition, optional: true
    belongs_to :release_type, optional: true

    validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true

    validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 1500, less_than_or_equal_to: ->(_album) { Date.current.year } }, allow_nil: true


    def artist_name
        artists.map(&:name)
    end

    def release_type_name
        release_type&.name
    end

    def medium_name
        medium&.name
    end

    def edition_name
        edition&.name
    end

end
