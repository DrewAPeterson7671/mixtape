FactoryBot.define do
  factory :priority do
    sequence(:name) { |n| "Priority #{n}" }
  end
end
