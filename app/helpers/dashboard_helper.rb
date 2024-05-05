# frozen_string_literal: true

# Helpers for dashboards#index
module DashboardHelper
  def time_based_greeting
    current_hour = Time.current.in_time_zone('Berlin').hour

    if current_hour < 12
      'Good Morning, '
    elsif current_hour < 18
      day_greetings.sample
    elsif current_hour < 22
      'Good Evening, '
    else
      'Good Night, '
    end
  end

  def time_based_emoji
    current_hour = Time.current.in_time_zone('Berlin').hour
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

  def day_greetings
    [
      'Hej, ',
      'Isn’t it a Lovely Day, ',
      'Hey there, ',
      'Have a Wonderful Day, ',
      'What’s Up, ',
      'Hey There, ',
      'Hals & Beinbrunch, '
    ]
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
