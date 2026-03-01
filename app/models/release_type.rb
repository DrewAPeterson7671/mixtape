class ReleaseType < ApplicationRecord
    validates :name, uniqueness: true
end
