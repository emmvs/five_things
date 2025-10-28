# frozen_string_literal: true

# Controller for dashboard functionalities including fetching & displaying HappyThings
class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_happy_things
  before_action :set_happy_things_of_today, only: [:index]

  def index
    @should_render_navbar = true
    @random_poem = fetch_random_poem
    @random_quote = fetch_random_quote
    @happy_thing = HappyThing.new
    @render_install_prompt = !current_user.user_config&.install_prompt_shown || false
  end

  private

  def fetch_random_poem
    PoetryService.call
  rescue SocketError => e
    Rails.logger.error("SocketError: #{e.message}")
    nil
  rescue StandardError => e
    Rails.logger.error("Error: #{e.message}")
    nil
  end

  def fetch_random_quote
    Rails.cache.fetch(daily_quote_cache_key, expires_in: 24.hours) do
      QuoteService.new('happiness').call
    rescue SocketError => e
      Rails.logger.error("SocketError: #{e.message}")
      nil
    rescue StandardError => e
      Rails.logger.error("Error: #{e.message}")
      nil
    end
  end

  def daily_quote_cache_key
    "random_quote_#{Date.today}"
  end

  def set_happy_things
    friend_ids = current_user.friends_and_friends_who_added_me_ids
    @user_ids = [current_user.id] + friend_ids

    @happy_things_of_you_and_friends = HappyThing.where(user_id: @user_ids).order(created_at: :desc)
    fetch_happy_things_by_time(friend_ids)
  end

  def fetch_happy_things_by_time(friend_ids)
    ids = with_current_user(friend_ids)
    @happy_things_today = happy_things_by_period(
      Date.today..Date.tomorrow, ids
    )

    @happy_things_of_the_last_two_days = happy_things_by_period(
      (Date.today - 1.days)..Date.today.end_of_day, ids
    )

    @happy_things_one_year_ago = HappyThing.where(
      'DATE(start_time) = ? AND user_id IN (?)', 1.year.ago.to_date, ids
    ).group_by(&:user)
  end

  def with_current_user(friend_ids)
    friend_ids + [current_user.id]
  end

  def happy_things_by_period(period, friend_ids)
    HappyThing.where(start_time: period, user_id: friend_ids).order(created_at: :desc).group_by(&:user)
  end

  def set_happy_things_of_today
    today = Date.today
    friend_ids = with_current_user(current_user.friends_and_friends_who_added_me_ids)
    @happy_things_by_date = HappyThing.where(
      'extract(month from start_time) = ? AND extract(day from start_time) = ? AND user_id IN (?)',
      today.month, today.day, friend_ids
    )
  end
end
