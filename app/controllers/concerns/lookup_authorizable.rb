# frozen_string_literal: true

module LookupAuthorizable
  extend ActiveSupport::Concern

  private

  def authorize_ownership!(record)
    return true if record.user_id == current_user.id

    head :forbidden
    false
  end

  def lookup_json(record)
    record.as_json.merge("system" => record.system?)
  end

  def lookup_collection_json(records)
    records.map { |r| lookup_json(r) }
  end
end
