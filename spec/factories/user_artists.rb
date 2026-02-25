FactoryBot.define do
  factory :user_artist do
    user
    artist
    rating { nil }
    complete { false }
    priority { nil }
    phase { nil }
  end
end
