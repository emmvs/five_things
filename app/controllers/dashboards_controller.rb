# frozen_string_literal: true

# Controller for dashboard functionalities including fetching and displaying HappyThings
class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_happy_things
  before_action :set_today_happy_things, only: [:index]

  def index
    @should_render_navbar = true
    @random_poem = PoetryService.call
    @random_quote = QuoteService.new('happiness').call
    @happy_thing = HappyThing.new
  end

  private

  # Sets various collections of HappyThings based on user's friends & specific time periods
  def set_happy_things
    friend_ids = current_user.friends_and_inverse_friends_ids
    user_ids = friend_ids + [current_user.id]

    @happy_things_of_you_and_friends = HappyThing.where(user_id: user_ids).order(created_at: :desc)
    fetch_periodic_happy_things(friend_ids)
  end

  # Fetch HappyThings f/ specific periods: today, last two days, and one year ago
  def fetch_periodic_happy_things(friend_ids)
    friend_ids_with_self = friend_ids + [current_user.id]
    @happy_things_today = happy_things_by_period(Date.today..Date.tomorrow, friend_ids_with_self)
    @happy_things_of_the_last_two_days = happy_things_by_period((Date.today - 1.days)..Date.today.end_of_day, friend_ids_with_self)
    @happy_things_one_year_ago = HappyThing.where('DATE(start_time) = ? AND user_id IN (?)', 1.year.ago.to_date, friend_ids_with_self).group_by(&:user)
  end

  # Helper to fetch HappyThings for a given period and user_ids
  def happy_things_by_period(period, friend_ids)
    HappyThing.where(start_time: period, user_id: friend_ids).order(created_at: :desc).group_by(&:user)
  end

  # Sets HappyThings for the current day
  def set_today_happy_things
    today = Date.today
    friend_ids = current_user.friends_and_inverse_friends_ids + [current_user.id]
    @happy_things_by_date = HappyThing.where('extract(month from start_time) = ? AND extract(day from start_time) = ? AND user_id IN (?)', today.month, today.day, friend_ids)
  end
end
