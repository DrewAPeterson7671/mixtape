FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "Tag #{n}" }
    comment { nil }
    user
  end
end
