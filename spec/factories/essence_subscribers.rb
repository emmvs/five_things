# frozen_string_literal: true

FactoryBot.define do
  factory :essence_subscriber do
    name { 'Emma Friend' }
    sequence(:email) { |n| "essence-#{n}@example.com" }
    locale { 'en' }

    trait :confirmed do
      confirmed_at { Time.zone.now }
    end

    trait :unsubscribed do
      confirmed_at { Time.zone.now }
      unsubscribed_at { Time.zone.now }
    end
  end
end
