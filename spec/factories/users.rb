FactoryBot.define do
  factory :user do
    cognito_sub { SecureRandom.uuid }
    email { Faker::Internet.email }
    name { Faker::Name.name }

    # Suppress the seed_default_lookups callback by default to keep tests fast
    # and avoid name collisions with factory-created lookup records.
    after(:build) do |user|
      user.define_singleton_method(:seed_default_lookups) { nil }
    end

    trait :with_default_lookups do
      after(:build) do |user|
        # Remove the singleton override so the real callback runs
        class << user
          remove_method :seed_default_lookups
        end
      end
    end
  end
end
