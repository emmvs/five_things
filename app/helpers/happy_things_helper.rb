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

  def grouped_visibility_options(user) # rubocop:disable Metrics/AbcSize
    group_options = user.groups.map { |g| ["🌟 #{g.name}", "group_#{g.id}"] }
    group_member_options = user.groups.flat_map do |group|
      group.friends.map do |friend|
        ["👤 #{friend.name} (#{group.name})", "friend_#{friend.id}"]
      end
    end

    other_friends = user.all_friends.reject do |f|
      user.groups.flat_map(&:friends).include?(f)
    end.map { |f| ["👤 #{f.name}", "friend_#{f.id}"] } # rubocop:disable Style/MultilineBlockChain

    group_options + group_member_options + other_friends
  end
end
