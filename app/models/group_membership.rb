# frozen_string_literal: true

# == Schema Information
#
# Table name: group_memberships
#
#  id         :bigint           not null, primary key
#  group_id   :bigint           not null
#  friend_id  :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :friend, class_name: 'User'
end
