# frozen_string_literal: true

FactoryBot.define do
  factory :happy_thing do
    title { 'Today I was happy' }
    body { Faker::Lorem.sentence }
    status { 0 }
    category { Category.first || association(:category) }
    user
    place { 'Berlin, Germany' }
    latitude { 52.52 }
    longitude { 13.405 }
    share_location { true }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
    start_time { Time.zone.now }
  end
end
