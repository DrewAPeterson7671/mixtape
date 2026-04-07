FactoryBot.define do
  factory :medium do
    sequence(:name) { |n| "Medium #{n}" }
    user { nil }
  end
end
