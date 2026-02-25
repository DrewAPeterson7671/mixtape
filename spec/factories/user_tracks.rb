FactoryBot.define do
  factory :user_track do
    user
    track
    rating { nil }
    listened { false }
  end
end
