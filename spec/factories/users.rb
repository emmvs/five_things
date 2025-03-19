# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { %w[Emmsi Leamaus Juanfairy].sample }
    email { Faker::Internet.unique.email }
    username { Faker::Internet.username }
    password { 'Secret_pa$$word_1' }
    emoji { '👻' }
    email_opt_in { false }
    location_opt_in { false }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
