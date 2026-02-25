FactoryBot.define do
  factory :track do
    title { Faker::Lorem.sentence(word_count: 3) }
    number { 1 }
    disc_number { 1 }
    artist
    album { nil }
    medium { nil }
  end
end
