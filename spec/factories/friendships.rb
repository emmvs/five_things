# frozen_string_literal: true

FactoryBot.define do
  factory :friendship do
    user
    friend { association :user }
  end
end
