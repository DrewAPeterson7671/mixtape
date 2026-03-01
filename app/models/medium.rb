class Medium < ApplicationRecord
    validates :name, uniqueness: true
end
