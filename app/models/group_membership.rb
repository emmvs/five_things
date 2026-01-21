# frozen_string_literal: true

# == Schema Information
#
# Table name: group_memberships
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  friend_id  :bigint           not null
#  group_id   :bigint           not null
#
# Indexes
#
#  index_group_memberships_on_friend_id  (friend_id)
#  index_group_memberships_on_group_id   (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (friend_id => users.id)
#  fk_rails_...  (group_id => groups.id)
#
class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :friend, class_name: 'User'
end
