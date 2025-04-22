# frozen_string_literal: true

# == Schema Information
#
# Table name: group_memberships
#
#  id         :bigint           not null, primary key
#  group_id   :bigint           not null (the group this membership belongs to)
#  friend_id  :bigint           not null (the user added to the group)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Associations:
#  belongs_to :group
#  belongs_to :friend (class_name: 'User')
#
class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :friend, class_name: 'User'
end
