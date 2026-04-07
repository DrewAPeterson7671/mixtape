FactoryBot.define do
  factory :edition do
    sequence(:name) { |n| "Edition #{n}" }
    user { nil }
  end
end
