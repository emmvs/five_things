# frozen_string_literal: true

# Controller for dashboard functionalities including fetching & displaying HappyThings
class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_happy_things
  before_action :set_happy_things_of_today, only: [:index]

  def index
    @random_poem = fetch_random_poem
    @random_quote = fetch_random_quote
    @happy_thing = HappyThing.new
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

  def fetch_happy_things_by_time(user_ids)
    @happy_things_today = happy_things_by_period(
      Date.today..Date.tomorrow, user_ids
    )

    @happy_things_of_the_last_two_days = happy_things_by_period(
      (Date.today - 1.days)..Date.today.end_of_day, user_ids
    )

    # currently unused
    # @happy_things_one_year_ago = HappyThing.where(
    #   'DATE(start_time) = ? AND user_id IN (?)', 1.year.ago.to_date, ids
    # ).group_by(&:user)
  end

  def set_user_ids
    [current_user.id] + current_user.friends_and_friends_who_added_me_ids
  end

  def happy_things_by_period(period, user_ids)
    HappyThing.where(start_time: period, user_id: user_ids).order(start_time: :desc).group_by(&:user)
  end

  def set_happy_things_of_today # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    today = Date.today
    user_ids = set_user_ids

    happy_things_past = HappyThing.where(
      'extract(month from start_time) = ? AND extract(day from start_time) = ? AND user_id IN (?)',
      today.month, today.day, user_ids
    )

    @happy_things_by_date = happy_things_past
                            .group_by { |happy_thing| happy_thing.start_time.year }
                            .reject { |year, _| year == today.year }
                            .sort.reverse.to_h
                            .transform_values { |year_happy_things| year_happy_things.group_by(&:user) }
  end
end
