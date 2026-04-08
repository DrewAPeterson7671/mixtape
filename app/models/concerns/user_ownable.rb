# frozen_string_literal: true

module UserOwnable
  extend ActiveSupport::Concern

  included do
    belongs_to :user

    validates :name, uniqueness: { scope: :user_id }
  end
end
