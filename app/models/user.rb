class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable

  has_many :happy_things
  has_many :friendships, foreign_key: 'user_id'
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id'
  has_many :friends, through: :friendships, source: :friend
  has_many :inverse_friends, through: :inverse_friendships, source: :user # Users who have listed this user as a friend
  has_many :comments
  has_many :likes

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

  # Calculates streak of consecutive days with happy things
  def happy_streak
    sorted_happy_things = happy_things.order(start_time: :desc)
    return 0 if sorted_happy_things.empty?

    unique_dates = sorted_happy_things.reject { |ht| ht.start_time.nil? }
                                      .map { |ht| ht.start_time.to_date }
                                      .uniq

    return 0 if unique_dates.empty?
    streak = 1

    unique_dates.each_cons(2) do |yesterday, today|
      break unless yesterday - today == 1
      streak += 1
    end

    streak
  end
end
