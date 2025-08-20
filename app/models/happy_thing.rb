# frozen_string_literal: true

# == Schema Information
#
# Table name: happy_things
#
#  id             :bigint           not null, primary key
#  title          :string           not null
#  body           :text
#  status         :integer
#  user_id        :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  start_time     :datetime
#  place          :string
#  latitude       :float
#  longitude      :float
#  category_id    :bigint
#  share_location :boolean
#
class HappyThing < ApplicationRecord
  geocoded_by :place

  belongs_to :user
  belongs_to :category
  has_many :comments, dependent: :destroy
  has_many :happy_thing_user_shares, dependent: :destroy
  has_many :shared_users, through: :happy_thing_user_shares, source: :friend
  has_many :happy_thing_group_shares, dependent: :destroy
  has_many :shared_groups, through: :happy_thing_group_shares, source: :group
  has_many :group_memberships, through: :shared_groups, source: :group_memberships
  has_one_attached :photo

  validates :title, presence: true

  before_validation :set_default_category, on: :create
  after_validation :geocode, if: :will_save_change_to_place?
  before_create :add_date_time_to_happy_thing, unless: :start_time_present?
  after_create :send_happy_email_to_friends
  # after_commit :send_happy_email_to_friends, on: :create
  # after_commit :send_happy_email_to_friends, on: :update, if: :start_date_changed?

  scope :today_for_user, lambda { |user|
    where(start_time: Time.zone.today.all_day, user:)
  }
  # scope :shared_from_user_with_friend, lambda { |user, friend|
  #   where(user:)
  #     .left_joins(:happy_thing_user_shares, :group_memberships)
  #     .where(
  #       'happy_thing_user_shares.friend_id = ? OR group_memberships.friend_id = ?',
  #       friend.id,
  #       friend.id
  #     )
  # }
  # confused since nil=public
  # move all share scoping here ?!
  # 


  attr_accessor :shared_with_ids

  def self.geocoded_markers
    geocoded.select(:latitude, :longitude).map do |ht|
      { lat: ht.latitude, lng: ht.longitude }
    end
  end

  def add_date_time_to_happy_thing
    self.start_time ||= Time.zone.now
  end

  def handle_visibility(shared_ids)
    p "hello handle_visibility #{shared_ids} 🐶"
    return if shared_ids.blank?

    shared_ids.each do |entry|
      type, id = entry.split('_')
      case type
      when 'group'
        happy_thing_group_shares.create!(group_id: id)
      when 'friend'
        happy_thing_user_shares.create!(friend_id: id)
      end
    end
  end

  private

  def set_default_category
    self.category ||= Category.find_by(name: 'General')
  end

  def start_time_present?
    start_time.present?
  end

  def friends_that_still_want_an_email
    friends_who_got_an_email_today = DailyHappyEmailDelivery
                                     .where(user:, delivered_at: Time.zone.today.all_day)
                                     .pluck(:recipient_id)

    user.friends_and_friends_who_added_me
        .where(email_opt_in: true)
        .where.not(id: friends_who_got_an_email_today)
  end

  def send_happy_email_to_friends
    # puts '🤡🤡🤡🤡'
    friends_that_still_want_an_email.each do |friend|
      # p HappyThing.today_for_user(user).shared_from_user_with_friend(user, friend).count
      # p HappyThing.today_for_user(user).count
      # p HappyThing.shared_from_user_with_friend(user, friend).count
      next unless HappyThing.today_for_user(user).count >= 5

      puts '🍌 before mail mailer sends'
      UserMailer.happy_things_notification(user, friend).deliver_later
    end
  end
end
