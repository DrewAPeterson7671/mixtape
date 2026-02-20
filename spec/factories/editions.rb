FactoryBot.define do
  factory :edition do
    sequence(:name) { |n| "Edition #{n}" }
  end
end
