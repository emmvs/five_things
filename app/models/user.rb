# frozen_string_literal: true
#
# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           default(""), not null
#  email_opt_in           :boolean          default(FALSE)
#  emoji                  :string
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  location_opt_in        :boolean          default(FALSE)
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  uid                    :string
#  unconfirmed_email      :string
#  username               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
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
         :recoverable, :rememberable, :validatable,
         :confirmable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  scope :all_except, ->(user) { where.not(id: user.id) }

  validates :first_name, presence: true,
                         length: { in: 3..30, message: I18n.t('errors.models.user.first_name.length') },
                         format: {
                           without: %r{http|https|www|<script.*?>|</script>}i,
                           message: I18n.t('errors.models.user.first_name.invalid')
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

  validates :provider, presence: true, on: :oauth_linking
  validates :uid, presence: true, on: :oauth_linking

  has_many :happy_things, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :happy_thing_user_shares, foreign_key: :friend_id, dependent: :destroy
  has_many :received_happy_things, through: :happy_thing_user_shares, source: :happy_thing
  has_many :group_memberships, foreign_key: :friend_id, dependent: :destroy
  has_many :groups_as_member, through: :group_memberships, source: :group

  # Friendships - Bidirectional: each friendship exists as two records
  has_many :friendships, dependent: :destroy
  has_many :friends, -> { where(friendships: { accepted: true }) }, through: :friendships, source: :friend
  has_many :pending_friends, -> { where(friendships: { accepted: false }) }, through: :friendships, source: :friend

  has_one_attached :avatar

  def self.search(query)
    where('first_name ILIKE :query OR last_name ILIKE :query OR username ILIKE :query OR email ILIKE :query',
          query: "%#{query}%")
  end

  def friend_ids
    friends.pluck(:id)
  end

  # Aliases for backward compatibility
  alias_method :friends_and_friends_who_added_me_ids, :friend_ids
  alias_method :all_friends, :friends

  def happy_streak
    return 0 if happy_things.empty?

    dates = happy_things_dates
    return 0 if dates.empty?

    calculate_streak(dates)
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

  def password_required?
    !persisted? || !password.nil?
  end

  private_class_method :generate_password_for_oauth, :generate_first_name_candidates
end
