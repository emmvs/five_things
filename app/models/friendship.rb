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

  after_create :create_inverse_friendship
  after_update :update_inverse_friendship, if: :saved_change_to_accepted?
  after_destroy :destroy_inverse_friendship

  private

  def create_inverse_friendship
    return if inverse_friendship_exists?

    self.class.create!(
      user_id: friend_id,
      friend_id: user_id,
      accepted:
    )
  end

  def update_inverse_friendship
    inverse = find_inverse_friendship
    inverse&.update(accepted:)
  end

  def destroy_inverse_friendship
    inverse = find_inverse_friendship
    inverse&.destroy
  end

  def find_inverse_friendship
    self.class.find_by(user_id: friend_id, friend_id: user_id)
  end

  def inverse_friendship_exists?
    self.class.exists?(user_id: friend_id, friend_id: user_id)
  end
end
