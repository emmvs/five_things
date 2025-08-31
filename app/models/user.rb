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
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  provider               :string
#  uid                    :string
#
class User < ApplicationRecord # rubocop:disable Metrics/ClassLength
  PASSWORD_REGEX = /\A
    (?=.*[a-z])       # at least one lowercase letter
    (?=.*[A-Z])       # at least one uppercase letter
    (?=.*\d)          # at least one digit
    (?=.*[^A-Za-z0-9])# at least one special character
    .{8,30}           # between 8 and 30 characters
  \z/x

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :confirmable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  scope :all_except, ->(user) { where.not(id: user.id) }

  validates :first_name, presence: true,
                         length: { in: 3..30, message: I18n.t('errors.models.user.first_name.length') },
                         format: {
                           without: %r{http|https|www|<script.*?>|</script>}i,
                           message: I18n.t('errors.models.user.first_name.format')
                         },
                         on: %i[create update oauth_linking]

  validates :password, presence: true,
                       length: { in: 8..30, message: I18n.t('errors.models.user.password.length') },
                       format: {
                         with: PASSWORD_REGEX,
                         message: I18n.t('errors.models.user.password.invalid')
                       },
                       confirmation: true,
                       if: :password_required?

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    length: { within: 3..255 }

  validates :provider, presence: true, on: :oauth_linking
  validates :uid, presence: true, on: :oauth_linking

  before_validation :normalize_email

  has_many :happy_things, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :happy_thing_user_shares, foreign_key: :friend_id, dependent: :destroy
  has_many :received_happy_things, through: :happy_thing_user_shares, source: :happy_thing
  has_many :group_memberships, foreign_key: :friend_id, dependent: :destroy
  has_many :groups_as_member, through: :group_memberships, source: :group

  # Friendships
  has_many :friendships, dependent: :destroy
  has_many :received_friend_requests, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy
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

  def self.from_omniauth(auth) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    # Returning user signing in via OAuth
    user = where(provider: auth.provider, uid: auth.uid).first

    # Manual-signup user now using OAuth for the first time
    # Match by email and attach provider/uid
    if user.nil?
      user = find_by(email: auth.info.email)
      if user
        user.assign_attributes(provider: auth.provider, uid: auth.uid)
        user.confirm unless user.confirmed?
        user.save!(context: :oauth_linking)
      end
    end

    # Brand new user via OAuth — create account from auth hash
    if user.nil?
      user = new(
        email: auth.info.email,
        first_name: extract_first_name(auth.info.name, auth.info.email),
        provider: auth.provider,
        uid: auth.uid,
        password: generate_password_for_oauth
      )
      user.skip_confirmation!
      user.save!
    end

    user
  end

  def self.extract_first_name(name, email)
    first_name_candidates = generate_first_name_candidates(name, email)

    first_name_candidates.each do |first_name_candidate|
      temp_user = User.new(first_name: first_name_candidate)
      temp_user.validate
      return first_name_candidate if temp_user.errors[:first_name].empty?
    end

    'User'
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

  def self.generate_first_name_candidates(name, email) # rubocop:disable Metrics/CyclomaticComplexity
    [
      name&.split&.first,
      name&.strip,
      email&.split('@')&.first&.split('.')&.first&.capitalize
    ]
  end

  def self.generate_password_for_oauth
    "Oauth1!#{SecureRandom.hex(4)}"
  end

  def normalize_email
    self.email = email.to_s.downcase.strip
  end

  def password_required?
    !persisted? || !password.nil?
  end

  def password_required?
    !persisted? || !password.nil?
  end

  private_class_method :generate_password_for_oauth, :generate_first_name_candidates
end
