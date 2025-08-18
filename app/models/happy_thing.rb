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
  has_many :likes
  has_many :comments
  has_many :happy_thing_user_shares, dependent: :destroy
  has_many :shared_users, through: :happy_thing_user_shares, source: :friend
  has_many :happy_thing_group_shares, dependent: :destroy
  has_many :shared_groups, through: :happy_thing_group_shares, source: :group
  has_one_attached :photo

  validates :title, presence: true

  before_validation :set_default_category, on: :create
  after_validation :geocode, if: :will_save_change_to_place?
  before_create :add_date_time_to_happy_thing, unless: :start_time_present?
  after_create :check_happy_things_count

  scope :today_for_user, ->(user) { where(start_time: Time.zone.today.all_day, user:) }

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

  def ai_title # rubocop:disable Metrics/MethodLength
    Rails.cache.fetch("#{cache_key_with_version}/content") do
      client = OpenAI::Client.new
      chaptgpt_response = client.chat(
        parameters: {
          model: 'gpt-4',
          messages: [{
            role: 'user',
            content: "Give me a simple thing to do that would make someone happy who is suffering from depression. Give me only the title, without any of your own weird metaphors or answers like 'Here is a simple happy thing.' Please ensure that the things are unique and suitable for intelligent people who need their brains stimulated by good things. It should fit into a text like so: 'Something to make you happy is\n todo.'"
          }]
        }
      )
      @ai_happy_thing = chaptgpt_response['choices'][0]['message']['content']
    end
  end

  private

  def set_default_category
    self.category ||= Category.find_by(name: 'General')
  end

  def start_time_present?
    start_time.present?
  end

  def check_happy_things_count
    today_count = user.happy_things.where(start_time: Time.zone.today.all_day).count
    return unless today_count == 5

    return if user.daily_happy_email_sent

    notify_friends_about_happy_things
    user.update(daily_happy_email_sent: true)
  end

  def notify_friends_about_happy_things
    user.friends_and_friends_who_added_me.where(email_opt_in: true).each do |friend|
      UserMailer.happy_things_notification(friend).deliver_later
    end
  end
end
