# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    name { 'Favorites' }
    association :user
  end
end
