FactoryBot.define do
  factory :phase do
    sequence(:name) { |n| "Phase #{n}" }
    user { nil }
  end
end
