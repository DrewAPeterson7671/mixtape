FactoryBot.define do
  factory :priority do
    sequence(:name) { |n| "Priority #{n}" }
    user { nil }
  end
end
