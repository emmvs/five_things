# frozen_string_literal: true

# == Schema Information
#
# Table name: groups
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_groups_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Group < ApplicationRecord
  belongs_to :user

  has_many :group_memberships, dependent: :destroy
  has_many :friends, through: :group_memberships, source: :friend
  has_many :happy_thing_group_shares, dependent: :destroy
  has_many :shared_happy_things, through: :happy_thing_group_shares, source: :happy_thing

  validates :name, presence: true
end
