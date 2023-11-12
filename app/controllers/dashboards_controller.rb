class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @should_render_navbar = true
    @happy_thing = HappyThing.new
    @happy_things_bubbles = HappyThing.all

    @happy_things = HappyThing.where(start_time: Date.today..Date.tomorrow).reverse.group_by(&:user)
    @happy_things_one_year_ago = HappyThing.where("DATE(start_time) = ?", 1.year.ago.to_date).order(created_at: :desc)

    # Fetch a random poem from a random author
    @random_poem = PoetryService.get_random_poem
  end
end
