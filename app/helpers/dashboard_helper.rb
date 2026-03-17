# frozen_string_literal: true

# Helpers for dashboards#index
module DashboardHelper
  def time_based_greeting(first_name, timezone = nil)
    key = greeting_key_for_hour(current_hour_in(timezone))
    t("dashboard.greetings.#{key}", name: first_name)
  end

  def time_based_emoji(timezone = nil) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    timezone ||= current_user&.timezone || 'UTC'
    current_hour = Time.current.in_time_zone(timezone).hour
    return moon_phase_emoji if current_hour >= 22 || current_hour < 6

    if current_hour < 12
      '🌤️'
    elsif current_hour < 18
      '☀️'
    else
      '✨'
    end
  end

  def moon_phase_emoji
    moon = MoonPhases.new
    fullness = moon.getMoonFullness(Date.current).getPercent.to_i
    moon_phase_emojis[find_moon_phase(fullness)]
  end

  private

  def current_hour_in(timezone)
    tz = timezone || current_user&.timezone || 'UTC'
    Time.current.in_time_zone(tz).hour
  end

  def greeting_key_for_hour(hour)
    return :go_to_bed if hour < 5
    return :good_morning if hour < 12
    return day_greeting_keys.sample if hour < 18
    return :good_evening if hour < 22

    :good_night
  end

  def day_greeting_keys
    %i[day_hej day_lovely_day day_hals_beinbruch day_wonderful_day day_whats_up day_hey_there]
  end

  def find_moon_phase(fullness)
    case fullness
    when 0 then :new_moon
    when 1..24 then :waxing_crescent
    when 25..49 then :first_quarter
    when 50..74 then :waxing_gibbous
    when 75..100 then :full_moon
    end
  end

  def moon_phase_emojis
    {
      new_moon: '🌑',
      waxing_crescent: '🌒',
      first_quarter: '🌙',
      waxing_gibbous: '🌔',
      full_moon: '🌕'
    }
  end
end
