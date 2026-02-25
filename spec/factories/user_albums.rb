FactoryBot.define do
  factory :user_album do
    user
    album
    rating { nil }
    listened { false }
  end
end
