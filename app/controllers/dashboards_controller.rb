class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @should_render_navbar = true
    @happy_thing = HappyThing.new
    @happy_things = HappyThing.all
    @happy_things_today = HappyThing.where(start_time: Date.today..Date.tomorrow).reverse.group_by(&:user)
    @happy_things_one_year_ago = HappyThing.where("DATE(start_time) = ?", 1.year.ago.to_date).order(created_at: :desc)

    @random_poem = fetch_daily_poem
  end

  private

  def fetch_daily_poem
    Rails.cache.fetch("random_poem", expires_in: 24.hours) do
      PoetryService.get_random_poem
    end
  end
end
