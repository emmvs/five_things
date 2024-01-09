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

  def happy_streak
    streak = 0
    last_date = nil

    happy_things.order(created_at: :desc).each do |happy_thing|
      break if last_date && (last_date - happy_thing.created_at).to_i > 1
      streak += 1
      last_date = happy_thing.created_at
    end

    streak
  end
end
