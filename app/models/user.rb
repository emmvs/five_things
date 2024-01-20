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
    date_of_most_recent_happy_thing = nil

    happy_things.order(start_time: :desc).each do |happy_thing|

      next if happy_thing.start_time.nil?

      current_date = happy_thing.start_time.to_date

      if date_of_most_recent_happy_thing.nil?
        streak = 1
      else
        # Check if the current HappyThing is on the consecutive day
        # The difference between date_of_most_recent_happy_thing (January 20)
        # and current_date (January 19) is 1 day. streak is incremented to 2
        if (date_of_most_recent_happy_thing - current_date).to_i == 1
          streak += 1
        else
          return streak
        end
      end

      date_of_most_recent_happy_thing = current_date
    end

    streak
  end
end
