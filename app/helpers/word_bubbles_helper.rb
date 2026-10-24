# frozen_string_literal: true

# Lays out the most used words as balls in a square box.
#
# The box is 100 by 100 units, and every position and size is in those units. The view turns
# them into percentages of the box width, so the layout looks the same on a phone and on desktop.
#
# How it works:
#   1. Every word gets a ball size: the more often it is used, the bigger the ball.
#   2. If the balls together are too big for the box, they are all scaled down.
#   3. Starting with the biggest, each ball is placed at the first free spot on a spiral
#      that starts in the middle of the box, so the biggest balls end up in the center.
#   4. If a ball doesn't fit anywhere, all balls shrink a little and we try again.
#   5. The finished group is moved to the middle of the box.
module WordBubblesHelper
  WORD_BUBBLE_LIMIT = 10
  BOX_SIZE = 100.0
  BOX_CENTER = BOX_SIZE / 2
  SMALLEST_RADIUS = 8.0
  BIGGEST_RADIUS = 22.0
  GAP_BETWEEN_BALLS = 1.5
  # How much of the box the balls may cover together before they are scaled down
  MAX_SHARE_OF_BOX = 0.5
  # Step 4: how many times to shrink, and by how much each time
  SHRINK_ATTEMPTS = 10
  SHRINK_FACTOR = 0.92
  # Step 3: how many points to try on the spiral, and how tightly it winds
  SPIRAL_POINTS = 3000
  SPIRAL_ANGLE_STEP = 0.1
  SPIRAL_DISTANCE_STEP = 0.05

  # words: [["coffee", 142], ["friends", 118], ...], most used first
  # Returns one hash per ball: { word:, count:, radius:, center_x:, center_y:, font_size: }
  def word_bubbles(words)
    top_words = words.first(WORD_BUBBLE_LIMIT)
    highest_count = top_words.map { |_word, count| count }.max.to_f
    radiuses = top_words.map { |_word, count| radius_for(count, highest_count) }
    place_all_bubbles(top_words, radiuses.map { |radius| radius * fit_in_box_scale(radiuses) })
  end

  # The position and size of one ball, as a style attribute for the view
  def word_bubble_style(bubble)
    format('left: %<left>.2f%%; top: %<top>.2f%%; width: %<width>.2f%%; font-size: %<font_size>.2fcqi;',
           left: bubble[:center_x] - bubble[:radius], top: bubble[:center_y] - bubble[:radius],
           width: bubble[:radius] * 2, font_size: bubble[:font_size])
  end

  private

  # Step 1. The square root keeps rarely used words from getting tiny balls
  def radius_for(count, highest_count)
    share_of_highest = Math.sqrt(count / highest_count)
    SMALLEST_RADIUS + (share_of_highest * (BIGGEST_RADIUS - SMALLEST_RADIUS))
  end

  # Step 2. 1 if the balls fit as they are, otherwise the factor that makes them fit
  def fit_in_box_scale(radiuses)
    area_of_balls = radiuses.sum { |radius| Math::PI * (radius**2) }
    allowed_area = MAX_SHARE_OF_BOX * (BOX_SIZE**2)
    [1, Math.sqrt(allowed_area / area_of_balls)].min
  end

  # Step 4. Try, and shrink all balls a little whenever one of them doesn't fit
  def place_all_bubbles(words, radiuses)
    SHRINK_ATTEMPTS.times do
      bubbles = place_bubbles(words, radiuses)
      return move_to_center(bubbles) if bubbles.size == words.size

      radiuses = radiuses.map { |radius| radius * SHRINK_FACTOR }
    end
    move_to_center(place_bubbles(words, radiuses))
  end

  # Step 3. Places the balls one by one, leaving out any that don't fit
  def place_bubbles(words, radiuses)
    words.zip(radiuses).each_with_object([]) do |((word, count), radius), placed_bubbles|
      center = free_center_on_spiral(radius, placed_bubbles)
      next unless center

      placed_bubbles << { word:, count:, radius:, center_x: center[0], center_y: center[1],
                          font_size: font_size_for(word, radius) }
    end
  end

  def free_center_on_spiral(radius, placed_bubbles)
    SPIRAL_POINTS.times do |point|
      angle = point * SPIRAL_ANGLE_STEP
      distance_from_center = point * SPIRAL_DISTANCE_STEP
      center = [BOX_CENTER + (distance_from_center * Math.cos(angle)),
                BOX_CENTER + (distance_from_center * Math.sin(angle))]
      return center if fits?(center, radius, placed_bubbles)
    end
    nil
  end

  # Inside the box and not touching any ball placed so far
  def fits?(center, radius, placed_bubbles)
    inside_box = center.all? { |coordinate| coordinate.between?(radius, BOX_SIZE - radius) }
    inside_box && placed_bubbles.none? { |bubble| overlaps?(bubble, center, radius) }
  end

  def overlaps?(bubble, center, radius)
    distance = Math.hypot(bubble[:center_x] - center[0], bubble[:center_y] - center[1])
    distance < bubble[:radius] + radius + GAP_BETWEEN_BALLS
  end

  # Step 5. The spiral fills the box unevenly, so shift every ball by the same amount
  def move_to_center(bubbles)
    shift_x = shift_to_center(bubbles, :center_x)
    shift_y = shift_to_center(bubbles, :center_y)
    bubbles.map { |bubble| bubble.merge(center_x: bubble[:center_x] + shift_x, center_y: bubble[:center_y] + shift_y) }
  end

  def shift_to_center(bubbles, axis)
    group_start = bubbles.map { |bubble| bubble[axis] - bubble[:radius] }.min
    group_end = bubbles.map { |bubble| bubble[axis] + bubble[:radius] }.max
    BOX_CENTER - ((group_start + group_end) / 2)
  end

  # Big enough to read, small enough that longer words stay inside their ball
  def font_size_for(word, radius)
    [radius * 0.55, radius * 2.8 / word.length].min
  end
end
