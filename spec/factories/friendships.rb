FactoryBot.define do
  factory :friendship do
    user
    friend { association :user }
  end
end
