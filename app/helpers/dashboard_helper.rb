# frozen_string_literal: true

# Helpers for dashboards#index
module DashboardHelper
  def time_based_greeting
    current_hour = Time.current.in_time_zone('Berlin').hour

    if current_hour < 12
      'Good Morning, '
    elsif current_hour < 18
      day_greetings.sample
    elsif current_hour < 22
      'Good Evening, '
    else
      'Good Night, '
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
      'Isn’t it a Lovely Day, ',
      'Hals & Beinbruch, ',
      'Have a Wonderful Day, ',
      'What’s Up, ',
      'Hey There, '
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

  # Calender
  def calculate_grid_size(number_of_emojis)
    return 2 if number_of_emojis == 1

    Math.sqrt(number_of_emojis).ceil
  end

  def calculate_emoji_size(number_of_emojis)
    grid_size = calculate_grid_size(number_of_emojis)
    case grid_size
    when 2 then 1.1
    when 3 then 0.8
    when 4 then 0.5
    else
      raise "Failure in calculate_emoji_size: number_of_emojis = #{number_of_emojis}, grid_size = #{grid_size}"
    end
  end

  def calculate_emoji_position(tile_number, number_of_emojis)
    return '0px, 0px' if number_of_emojis > 4

    case tile_number
    when 1 then '-4px, -5px'
    when 2 then '4px, -5px'
    when 3 then '-4px, 5px'
    when 4 then '4px, 5px'
    else
      raise "Failure in calculate_emoji_position: number_of_emojis = #{number_of_emojis}, tile_number = #{tile_number}"
    end
  end
end
