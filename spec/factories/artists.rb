FactoryBot.define do
  factory :artist do
    sequence(:name) { |n| "#{Faker::Music.band} #{n}" }
    wikipedia_discography { nil }
    discogs { nil }
  end
end
