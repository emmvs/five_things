# frozen_string_literal: true

# == Schema Information
#
# Table name: happy_thing_group_shares
#
#  id             :bigint           not null, primary key
#  happy_thing_id :bigint           not null
#  group_id       :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class HappyThingGroupShare < ApplicationRecord
  belongs_to :happy_thing
  belongs_to :group
end
