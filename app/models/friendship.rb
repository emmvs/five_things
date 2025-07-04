# frozen_string_literal: true

# == Schema Information
#
# Table name: friendships
#
#  id         :bigint           not null, primary key
#  user_id    :bigint
#  friend_id  :bigint
#  accepted   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Friendship Model which makes sure a friendship is always either false or true (accepted)
class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  scope :accepted, -> { where(accepted: true) }
  scope :pending, -> { where(accepted: false) }

  validates :accepted, inclusion: { in: [true, false] }
end
