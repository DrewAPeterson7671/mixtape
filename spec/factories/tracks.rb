FactoryBot.define do
  factory :track do
    title { Faker::Lorem.sentence(word_count: 3) }
    medium { nil }
    duration { nil }
    isrc { nil }
  end
end
