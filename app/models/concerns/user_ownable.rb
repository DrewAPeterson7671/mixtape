# frozen_string_literal: true

module UserOwnable
  extend ActiveSupport::Concern

  included do
    belongs_to :user, optional: true

    scope :visible_to, ->(user) { where(user_id: [nil, user.id]) }
    scope :system_records, -> { where(user_id: nil) }
    scope :owned_by, ->(user) { where(user_id: user.id) }

    validate :name_unique_within_visible_set
  end

  def system?
    user_id.nil?
  end

  def owned_by?(user)
    user_id == user.id
  end

  private

  def name_unique_within_visible_set
    return if name.blank?

    scope = self.class.where(name: name)

    if user_id.nil?
      # System record: name must not already exist as a system record
      scope = scope.where(user_id: nil)
    else
      # User record: name must not exist as system OR as same user's record
      scope = scope.where(user_id: [nil, user_id])
    end

    scope = scope.where.not(id: id) if persisted?

    errors.add(:name, "has already been taken") if scope.exists?
  end
end
