# frozen_string_literal: true

# Service to fetch and process Oura health data
# Business logic layer that uses OuraClient for API communication
# Documentation: https://cloud.ouraring.com/v2/docs
class OuraService
  def initialize(user)
    @user = user
  end

  def connected?
    @user.oura_access_token.present? && !token_expired?
  end

  def token_expired?
    @user.oura_token_expires_at.present? && @user.oura_token_expires_at < Time.current
  end

  # Fetch daily activity data
  def daily_activity(start_date: 7.days.ago.to_date, end_date: Date.today)
    fetch_data('usercollection/daily_activity', start_date:, end_date:)
  end

  # Fetch daily sleep data
  def daily_sleep(start_date: 7.days.ago.to_date, end_date: Date.today)
    fetch_data('usercollection/daily_sleep', start_date:, end_date:)
  end

  # Fetch heart rate data
  def heart_rate(start_datetime: 24.hours.ago, end_datetime: Time.current)
    fetch_data('usercollection/heartrate', start_datetime:, end_datetime:)
  end

  # Fetch workout data
  def workouts(start_date: 7.days.ago.to_date, end_date: Date.today)
    fetch_data('usercollection/workout', start_date:, end_date:)
  end

  # Fetch session data (meditation, breathing, etc.)
  def sessions(start_date: 7.days.ago.to_date, end_date: Date.today)
    fetch_data('usercollection/session', start_date:, end_date:)
  end

  # Fetch tag data (moments, notes)
  def tags(start_date: 7.days.ago.to_date, end_date: Date.today)
    fetch_data('usercollection/tag', start_date:, end_date:)
  end

  # Get summary of today's data
  def today_summary
    return { error: 'Not connected to Oura' } unless connected?

    {
      activity: daily_activity(start_date: Date.today, end_date: Date.today),
      sleep: daily_sleep(start_date: Date.yesterday, end_date: Date.today),
      workouts: workouts(start_date: Date.today, end_date: Date.today)
    }
  end

  # Calculate sleep quality trend over last 7 days
  def sleep_trend
    return nil unless connected?

    sleep_data = daily_sleep(start_date: 7.days.ago.to_date, end_date: Date.today)
    return nil unless sleep_data['data'].present?

    scores = sleep_data['data'].map { |day| day['score'] }.compact
    return nil if scores.empty?

    {
      average: (scores.sum.to_f / scores.size).round,
      min: scores.min,
      max: scores.max,
      trend: calculate_trend(scores)
    }
  end

  # Get latest sleep score
  def latest_sleep_score
    return nil unless connected?

    sleep_data = daily_sleep(start_date: Date.yesterday, end_date: Date.today)
    sleep_data.dig('data', 0, 'score')
  end

  private

  def fetch_data(endpoint, **params)
    return { error: 'Not connected to Oura' } unless connected?

    # Refresh token if expired
    refresh_token! if token_expired?

    client.get(endpoint, params: format_params(params))
  rescue OuraClient::AuthenticationError => e
    Rails.logger.error("Oura authentication error for user #{@user.id}: #{e.message}")
    # Token might be invalid, try refresh
    refresh_token!
    retry
  rescue OuraClient::RateLimitError => e
    Rails.logger.warn("Oura rate limit hit for user #{@user.id}: #{e.message}")
    { error: 'Rate limit exceeded, please try again later' }
  rescue OuraClient::OuraError => e
    Rails.logger.error("Oura client error for user #{@user.id}: #{e.message}")
    { error: e.message }
  rescue StandardError => e
    Rails.logger.error("Unexpected error in OuraService for user #{@user.id}: #{e.message}")
    { error: 'An unexpected error occurred' }
  end

  def client
    @client ||= OuraClient.new(access_token: @user.oura_access_token)
  end

  def format_params(params)
    formatted = {}

    formatted[:start_date] = params[:start_date].to_s if params[:start_date]
    formatted[:end_date] = params[:end_date].to_s if params[:end_date]
    formatted[:start_datetime] = params[:start_datetime].utc.iso8601 if params[:start_datetime]
    formatted[:end_datetime] = params[:end_datetime].utc.iso8601 if params[:end_datetime]

    formatted
  end

  def refresh_token!
    token_data = OuraClient.refresh_token(
      refresh_token: @user.oura_refresh_token,
      client_id: ENV.fetch('OURA_CLIENT_ID'),
      client_secret: ENV.fetch('OURA_CLIENT_SECRET')
    )

    @user.update(
      oura_access_token: token_data['access_token'],
      oura_refresh_token: token_data['refresh_token'],
      oura_token_expires_at: token_data['expires_in'].seconds.from_now
    )

    # Reset client with new token
    @client = nil

    Rails.logger.info("Refreshed Oura token for user #{@user.id}")
  rescue OuraClient::AuthenticationError => e
    Rails.logger.error("Failed to refresh Oura token for user #{@user.id}: #{e.message}")
    raise
  end

  def calculate_trend(scores)
    return 'stable' if scores.size < 2

    first_half = scores.first(scores.size / 2)
    second_half = scores.last(scores.size / 2)

    first_avg = first_half.sum.to_f / first_half.size
    second_avg = second_half.sum.to_f / second_half.size

    diff = second_avg - first_avg

    if diff > 5
      'improving'
    elsif diff < -5
      'declining'
    else
      'stable'
    end
  end
end
