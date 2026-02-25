FactoryBot.define do
  factory :playlist do
    sequence(:name) { |n| "Playlist #{n}" }
    platform { "Spotify" }
    user
    genre
    year { 2020 }
  end
end
