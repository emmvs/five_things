class HappyThing < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  default_scope { order(created_at: :desc) }

  def start_time
    self.date
    # @date = HappyThing.find(params[:date]) ? Date.parse(params[:date]) : Date.today
  end
end
