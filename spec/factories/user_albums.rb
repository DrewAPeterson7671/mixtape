FactoryBot.define do
  factory :user_album do
    user
    album
    rating { nil }
    listened { false }
    consider_editions { false }
  end
end
