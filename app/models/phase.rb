class Phase < ApplicationRecord
    validates :name, uniqueness: true
end
