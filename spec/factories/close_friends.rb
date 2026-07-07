# frozen_string_literal: true

FactoryBot.define do
  factory :close_friends_issue do
    title { 'A note from the road' }
    body { "Hello close friends.\n\nThis is issue one." }
    association :created_by, factory: :user

    trait :published do
      published_at { Time.current }
    end

    trait :sent do
      published_at { 1.hour.ago }
      sent_at { Time.current }
    end
  end

  factory :close_friends_subscriber do
    name { 'Emma' }
    sequence(:email) { |n| "close-friend-#{n}@example.com" }

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :approved do
      confirmed_at { Time.current }
      approved_at { Time.current }
    end

    trait :unsubscribed do
      confirmed_at { Time.current }
      approved_at { Time.current }
      unsubscribed_at { Time.current }
    end
  end
end
