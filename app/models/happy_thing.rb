class HappyThing < ApplicationRecord
  belongs_to :user
  validates :title, presence: true

  default_scope { order(created_at: :desc) }
  before_create :add_date_time_to_happy_thing, unless: :start_time_present?

  has_one_attached :photo

  def add_date_time_to_happy_thing
    self.start_time = DateTime.now
  end

  private

  def start_time_present?
    start_time.present?
  end
end
