FactoryBot.define do
  factory :epoch do
    sequence(:name) { |n| "Epoch #{n}" }
    user
  end
end
