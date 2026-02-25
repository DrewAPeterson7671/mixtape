FactoryBot.define do
  factory :user do
    cognito_sub { SecureRandom.uuid }
    email { Faker::Internet.email }
    name { Faker::Name.name }
  end
end
