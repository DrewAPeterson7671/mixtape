FactoryBot.define do
  factory :artist do
    sequence(:name) { |n| "#{Faker::Music.band} #{n}" }
    wikipedia { nil }
    discogs { nil }
  end
end
