# frozen_string_literal: true

# Helper methods for HappyThing views
module HappyThingsHelper
  # Formats dates as 'Today', 'Yesterday', or 'Month Day' with an ordinal suffix
  def friendly_date(date)
    case (Date.current - date.to_date).to_i
    when 0
      'Today'
    when 1
      'Yesterday'
    else
      "#{date.strftime('%B %-d')}#{date.strftime('%d').to_i.ordinal}"
    end
  end

  def use_long_title_layout?(happy_thing)
    base_threshold = 93
    date_string_subtraction = friendly_date(happy_thing.start_time).length
    photo_emoji_subtraction = happy_thing.photo.attached? ? 6 : 0
    comments_emoji_subtraction = happy_thing.comments.any? ? 6 : 0

    threshold = base_threshold - photo_emoji_subtraction - date_string_subtraction - comments_emoji_subtraction
    happy_thing.title.length >= threshold
  end

  def grouped_visibility_options(user) # rubocop:disable Metrics/AbcSize
    group_options = user.groups.map { |g| ["🌟 #{g.name}", "group_#{g.id}"] }
    group_member_options = user.groups.flat_map do |group|
      group.friends.map do |friend|
        ["👤 #{friend.first_name} #{friend.last_name} (#{group.name})", "friend_#{friend.id}"]
      end
    end

    other_friends = user.all_friends.reject do |f|
      user.groups.flat_map(&:friends).include?(f)
    end.map { |f| ["👤 #{f.first_name} #{f.last_name}", "friend_#{f.id}"] } # rubocop:disable Style/MultilineBlockChain

    group_options + group_member_options + other_friends
  end
end
