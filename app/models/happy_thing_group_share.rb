# frozen_string_literal: true

# == Schema Information
#
# Table name: happy_thing_group_shares
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  group_id       :bigint           not null
#  happy_thing_id :bigint           not null
#
# Indexes
#
#  index_happy_thing_group_shares_on_group_id        (group_id)
#  index_happy_thing_group_shares_on_happy_thing_id  (happy_thing_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (happy_thing_id => happy_things.id)
#
class HappyThingGroupShare < ApplicationRecord
  belongs_to :happy_thing
  belongs_to :group
end
