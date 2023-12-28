class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @should_render_navbar = true
    set_happy_things
    @random_poem = fetch_daily_poem
    @random_quote = fetch_daily_quote
  end

  private

  def set_happy_things
    @happy_things = HappyThing.all
    @happy_things_today = happy_things_by_period(Date.today..Date.tomorrow)
    @happy_things_of_the_last_two_days = happy_things_by_period((Date.today - 2.days)..Date.today.end_of_day)
    @happy_things_one_year_ago = HappyThing.where("DATE(start_time) = ?", 1.year.ago.to_date).order(created_at: :desc)
  end

  def happy_things_by_period(period)
    HappyThing.where(start_time: period).reverse.group_by(&:user)
  end

  def fetch_daily_quote
    quote_service = QuoteService.new('happiness')
    quote_info = quote_service.call
  end

  def fetch_daily_poem
    PoetryService.call
  end
end
