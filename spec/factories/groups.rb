FactoryBot.define do
  factory :group do
    name { 'Favorites' }
    association :user
  end
end
