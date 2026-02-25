FactoryBot.define do
  factory :release_type do
    sequence(:name) { |n| "ReleaseType #{n}" }
  end
end
