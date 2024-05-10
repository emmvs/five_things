# frozen_string_literal: true

# HappyThing Model
class HappyThing < ApplicationRecord
  # default_scope { order(created_at: :desc) }
  # scope :of_friends, ->(user) {
  #   friend_ids = user.friends.ids + user.inverse_friends.ids
  #   where(user_id: friend_ids + [user.id])
  # }

  geocoded_by :place

  belongs_to :user
  belongs_to :category

  has_many :likes
  has_many :comments

  before_validation :set_default_category, on: :create
  validates :title, presence: true
  after_validation :geocode, if: :will_save_change_to_place?

  before_create :add_date_time_to_happy_thing, unless: :start_time_present?
  after_create :check_happy_things_count

  has_one_attached :photo

  def self.geocoded_markers
    geocoded.select(:latitude, :longitude).map do |ht|
      { lat: ht.latitude, lng: ht.longitude }
    end
  end

  def add_date_time_to_happy_thing
    self.start_time ||= Time.zone.now
  end

  def ai_title # rubocop:disable Metrics/MethodLength
    Rails.cache.fetch("#{cache_key_with_version}/content") do
      client = OpenAI::Client.new
      chaptgpt_response = client.chat(
        parameters: {
          model: 'gpt-4',
          messages: [{
            role: 'user',
            content: "Give me a simple thing to do that would make someone happy who is suffering from depression. Give me only the title, without any of your own weird metaphors or answers like 'Here is a simple happy thing.' Please ensure that the things are unique and suitable for intelligent people who need their brains stimulated by good things. It should fit into a text like so: 'Something to make you happy is\n todo.'"}]
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
    count_today = user.happy_things.where('created_at >= ?', Time.zone.now.beginning_of_day).count
    return unless count_today == 5

    user.friends.each do |friend|
      UserMailer.happy_things_notification(friend).deliver_now
    end
  end
end
