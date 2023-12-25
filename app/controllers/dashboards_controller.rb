class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @should_render_navbar = true
    @happy_thing = HappyThing.new
    @happy_things = HappyThing.all
    @happy_things_today = HappyThing.where(start_time: Date.today..Date.tomorrow).reverse.group_by(&:user)
    @happy_things_of_the_last_two_days = HappyThing.where(start_time: (Date.today - 2.days)..Date.today.end_of_day).reverse.group_by(&:user)
    @happy_things_one_year_ago = HappyThing.where("DATE(start_time) = ?", 1.year.ago.to_date).order(created_at: :desc)

    @random_poem = fetch_daily_poem
    @random_quote = fetch_daily_quote
  end

  private

  def fetch_daily_poem
    Rails.cache.fetch("random_poem", expires_in: 24.hours) do
      PoetryService.get_random_poem
    end
  end

  def fetch_daily_quote
    quote_service = QuoteService.new('happiness')
    quote = quote_service.fetch_random_quote
    puts quote unless quote.nil?
  end
end
