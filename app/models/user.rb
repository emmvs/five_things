# frozen_string_literal: true

# User Model w/ HappyStreak & Friendships
class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  scope :all_except, ->(user) { where.not(id: user.id) }

  validates :first_name, presence: true, format: { without: /http|https|www/i }
  validates :password, presence: true, format: { without: /(<script.*?>|<\/script>)/i }

  has_many :happy_things
  has_many :comments
  has_many :likes

  # Friendships
  has_many :friendships
  # has_many :friendships, foreign_key: 'user_id'
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id'
  has_many :friends, -> { where(friendships: { accepted: true }) }, through: :friendships, source: :friend
  # Users who have listed this user as a friend
  has_many :inverse_friends, -> { where(friendships: { accepted: true }) }, through: :inverse_friendships, source: :user

  has_one_attached :avatar

  def self.search(query)
    where('first_name ILIKE :query OR last_name ILIKE :query OR username ILIKE :query OR email ILIKE :query',
          query: "%#{query}%")
  end

  def friends_and_inverse_friends_ids
    friends.pluck(:id) + inverse_friends.pluck(:id)
  end

  def all_friends
    friends + inverse_friends
  end

  def accepted_friends
    friendships.where(status: :accepted)
  end

  def pending_friends
    friendships.pending + inverse_friendships.pending
  end

  def happy_streak
    return 0 if happy_things.empty?

    dates = happy_things_dates
    return 0 if dates.empty?

    calculate_streak(dates)
  end

  private

  def happy_things_dates
    happy_things.reorder(start_time: :desc)
                .pluck(:start_time)
                .compact
                .map(&:to_date)
                .uniq
  end

  def calculate_streak(dates)
    dates.each_cons(2).with_object(streak: 1) do |(yesterday, today), accumulator|
      break accumulator[:streak] unless yesterday - today == 1

      accumulator[:streak] += 1
    end
  end
end
