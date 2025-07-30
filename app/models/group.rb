# frozen_string_literal: true

# == Schema Information
#
# Table name: groups
#
#  id         :bigint           not null, primary key
#  name       :string
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Group < ApplicationRecord
  belongs_to :user

  has_many :group_memberships, dependent: :destroy
  has_many :friends, through: :group_memberships, source: :friend
  has_many :happy_thing_group_shares, dependent: :destroy
  has_many :shared_happy_things, through: :happy_thing_group_shares, source: :happy_thing

  validates :name, presence: true
end
