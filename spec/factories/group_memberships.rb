FactoryBot.define do
  factory :group_membership do
    association :group
    association :friend, factory: :user
  end
end
