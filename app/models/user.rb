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

  # Calculates streak of consecutive days with happy things
  # Each 'happy thing' is an event marked with a start_time
  def happy_streak
    sorted_happy_things = happy_things.order(start_time: :desc)

    return 0 if sorted_happy_things.empty?

    # Initialize the streak count and set the most recent date to the first item's date
    previous_date = sorted_happy_things.first.start_time.to_date
    streak = 1

    # Iterate over the sorted happy things, starting from the second item
    # Break the loop if the current date is not consecutive to the previous one
    # Increment the streak and update the previous_date for the next iteration
    sorted_happy_things.drop(1).each do |happy_thing|
      current_date = happy_thing.start_time.to_date
      if previous_date - current_date == 1
        streak += 1
        previous_date = current_date
      else
        break
      end
    end

    streak
  end

end
