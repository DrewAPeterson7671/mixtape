FactoryBot.define do
  factory :genre do
    sequence(:name) { |n| "Genre #{n}" }
    user { nil }
  end
end
