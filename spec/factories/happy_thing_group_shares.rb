# frozen_string_literal: true

FactoryBot.define do
  factory :happy_thing_group_share do
    association :happy_thing
    association :group
  end
end
