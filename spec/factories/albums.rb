FactoryBot.define do
  factory :album do
    title { Faker::Music.album }
    year { 2020 }
    medium { nil }
    edition { nil }
    release_type { nil }
  end
end
