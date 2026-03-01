class Priority < ApplicationRecord
    validates :name, uniqueness: true
end
