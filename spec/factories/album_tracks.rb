FactoryBot.define do
  factory :album_track do
    album
    track
    position { 1 }
    disc_number { 1 }
  end
end
