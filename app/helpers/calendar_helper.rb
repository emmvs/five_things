# frozen_string_literal: true

module CalendarHelper
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
