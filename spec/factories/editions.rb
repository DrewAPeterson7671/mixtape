FactoryBot.define do
  factory :edition do
    sequence(:name) { |n| "Edition #{n}" }
    user
  end
end
