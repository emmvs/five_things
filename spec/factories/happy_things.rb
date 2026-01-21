# frozen_string_literal: true

# == Schema Information
#
# Table name: happy_things
#
#  id             :bigint           not null, primary key
#  body           :text
#  latitude       :float
#  longitude      :float
#  place          :string
#  share_location :boolean
#  start_time     :datetime
#  status         :integer
#  title          :string           not null
#  visibility     :string           default("public")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  category_id    :bigint
#  user_id        :bigint           not null
#
# Indexes
#
#  index_happy_things_on_category_id  (category_id)
#  index_happy_things_on_user_id      (user_id)
#  index_happy_things_on_visibility   (visibility)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (user_id => users.id)
#
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
