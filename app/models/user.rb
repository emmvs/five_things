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
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  failed_attempts        :integer          default(0), null: false
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  emoji                  :string
#  email_opt_in           :boolean          default(FALSE)
#  location_opt_in        :boolean          default(FALSE)
#  username               :string
#  provider               :string
#  uid                    :string
# 
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :omniauthable, omniauth_providers: [:google_oauth2] 
         # TODO: Add :trackable, :lockable

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
                         with: /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,30}/,
                         message: I18n.t('errors.models.user.password.invalid')
                       }

  has_many :happy_things
  has_many :comments
  has_many :likes
  has_many :groups, dependent: :destroy
  has_many :happy_thing_user_shares, foreign_key: :friend_id, dependent: :destroy
  has_many :received_happy_things, through: :happy_thing_user_shares, source: :happy_thing
  has_many :group_memberships, foreign_key: :friend_id
  has_many :groups_as_member, through: :group_memberships, source: :group

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

  def friends_and_friends_who_added_me
    User.where(id: friends_and_friends_who_added_me_ids)
  end

  def self.from_omniauth(auth)
    # Returning user signing in via OAuth
    user = where(provider: auth.provider, uid: auth.uid).first
    
    # Manual-signup user now using OAuth for the first time
    # Match by email and attach provider/uid
    if user.nil?
      user = find_by(email: auth.info.email)
      if user
        user.provider = auth.provider
        user.uid = auth.uid
        user.save!(validate: false)  # Skip password validations - user already has valid encrypted password from initial signup
      end
    end
    
    # Brand new user via OAuth — create account from auth hash
    if user.nil?
      user = create!(
        email: auth.info.email,
        first_name: auth.info.name&.split&.first || 'User',
        provider: auth.provider,
        uid: auth.uid,
        password: generate_password_for_oauth
      )
    end
    
    # All OAuth users are auto-confirmed to skip email verification
    user.confirm unless user.confirmed?
    
    user
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
    streak = 1
    dates.each_cons(2) do |yesterday, today|
      break streak unless (yesterday - today) == 1

      streak += 1
    end
    streak
  end

  def self.generate_password_for_oauth
    "Oauth1!#{SecureRandom.hex(4)}"
  end
end
