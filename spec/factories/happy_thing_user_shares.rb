FactoryBot.define do
  factory :happy_thing_user_share do
    happy_thing
    friend { association :user }
  end
end
