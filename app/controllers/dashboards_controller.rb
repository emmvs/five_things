# frozen_string_literal: true

# DashboardsController is in charge of setting the HappyThings for our index page
class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @should_render_navbar = true
    set_happy_things
    @random_poem = fetch_daily_poem
    @random_quote = fetch_daily_quote
    @happy_thing = HappyThing.new
  end

  private

  def set_happy_things
    friend_ids = current_user.friends.pluck(:id) + current_user.inverse_friends.pluck(:id) + [current_user.id]
    @happy_things = HappyThing.where(user_id: friend_ids)
    @happy_things_today = happy_things_by_period(Date.today..Date.tomorrow, friend_ids)
    @happy_things_of_the_last_two_days = happy_things_by_period((Date.today - 1.days)..Date.today.end_of_day, friend_ids)
    @happy_things_one_year_ago = HappyThing.where("DATE(start_time) = ? AND user_id IN (?)", 1.year.ago.to_date, friend_ids).order(created_at: :desc)
  end

  def happy_things_by_period(period, friend_ids)
    HappyThing.where(start_time: period, user_id: friend_ids).reverse.group_by(&:user)
  end

  def fetch_daily_quote
    quote_service = QuoteService.new('happiness')
    quote_service.call
  end

  def fetch_daily_poem
    PoetryService.call
  end
end
