class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable

  has_many :happy_things
  has_many :friendships, foreign_key: 'user_id'
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id'
  has_many :friends, through: :friendships, source: :friend
  has_many :inverse_friends, through: :inverse_friendships, source: :user # Users who have listed this user as a friend

  has_one_attached :avatar

  def all_friends
    friends + inverse_friends
  end

  def accepted_friends
    friendships.where(status: :accepted)
  end

  def pending_friends
    friendships.where(status: :pending)
  end

  def can_add_as_friend?(current_user, potential_friend)
    return false if current_user.friends.include?(potential_friend)

    direct_friendship = current_user.friendships.find_by(friend_id: potential_friend.id)
    inverse_friendship = potential_friend.friendships.find_by(user_id: current_user.id)

    !(direct_friendship || inverse_friendship)
  end
end
