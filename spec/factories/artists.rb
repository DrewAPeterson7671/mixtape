FactoryBot.define do
  factory :artist do
    sequence(:name) { |n| "#{Faker::Music.band} #{n}" }
    wikipedia_discography { nil }
    discogs { nil }
    notes { nil }
    wikipedia { nil }
    official_page { nil }
    bandcamp { nil }
    last_fm { nil }
    google_genre_link { nil }
    all_music { nil }
    all_music_discography { nil }
  end
end
