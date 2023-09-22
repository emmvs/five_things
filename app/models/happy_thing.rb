class HappyThing < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  default_scope { order(created_at: :desc) }
  before_create :add_date_time_to_happy_thing

  def add_date_time_to_happy_thing
    self.start_time = DateTime.now
  end
end
