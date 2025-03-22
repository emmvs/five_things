# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  first_name             :string
#  last_name              :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  emoji                  :string
#  email_opt_in           :boolean          default(FALSE)
#  location_opt_in        :boolean          default(FALSE)
#  username               :string
#
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  scope :all_except, ->(user) { where.not(id: user.id) }

  validates :first_name, presence: true,
                         length: { in: 3..30, message: I18n.t('errors.models.user.first_name.length') },
                         format: {
                           without: %r{http|https|www|<script.*?>|</script>}i,
                           message: I18n.t('errors.models.user.first_name.invalid')
                         }

  validates :password, presence: true,
                       length: { in: 8..30, message: I18n.t('errors.models.user.password.length') },
                       format: {
                         with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,30}\z/,
                         message: I18n.t('errors.models.user.password.invalid')
                       }

  has_many :happy_things
  has_many :comments
  has_many :likes

  # Friendships
  has_many :friendships
  has_many :received_friend_requests, class_name: 'Friendship', foreign_key: 'friend_id'
  has_many :friends, -> { where(friendships: { accepted: true }) }, through: :friendships, source: :friend
  has_many :friends_who_added_me, lambda {
                                    where(friendships: { accepted: true })
                                  }, through: :received_friend_requests, source: :user

  has_one_attached :avatar

  def self.search(query)
    where('first_name ILIKE :query OR last_name ILIKE :query OR username ILIKE :query OR email ILIKE :query',
          query: "%#{query}%")
  end

  def friends_and_friends_who_added_me_ids
    friends.pluck(:id) + friends_who_added_me.pluck(:id)
  end

  def all_friends
    friends + friends_who_added_me
  end

  def accepted_friends
    friendships.where(status: :accepted)
  end

  def pending_friends
    friendships.pending + received_friend_requests.pending
  end

  def happy_streak
    return 0 if happy_things.empty?

    dates = happy_things_dates
    return 0 if dates.empty?

    calculate_streak(dates)
  end

  private

  def password_required?
    password.present? || new_record?
  end

  def happy_things_dates
    happy_things.reorder(start_time: :desc)
                .pluck(:start_time)
                .compact
                .map(&:to_date)
                .uniq
  end

  def calculate_streak(dates)
    streak = 1
    dates.each_cons(2) do |yesterday, today|
      break streak unless (yesterday - today) == 1

      streak += 1
    end
    streak
  end
end
