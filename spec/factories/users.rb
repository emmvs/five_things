FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    email { Faker::Internet.unique.email }
    password { "123456" }
  end
end
