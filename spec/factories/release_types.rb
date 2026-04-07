FactoryBot.define do
  factory :release_type do
    sequence(:name) { |n| "ReleaseType #{n}" }
    user { nil }
  end
end
