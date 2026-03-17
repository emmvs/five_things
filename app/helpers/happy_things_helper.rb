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

  def grouped_visibility_options(user) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    only_me = [[I18n.t('happy_things.only_me'), 'only_me']]

    group_options = user.groups.map { |g| ["🌟 #{g.name}", "group_#{g.id}"] }
    group_member_options = user.groups.flat_map do |group|
      group.friends.map do |friend|
        ["👤 #{friend.name} (#{group.name})", "friend_#{friend.id}"]
      end
    end

    other_friends = user.all_friends.reject do |f|
      user.groups.flat_map(&:friends).include?(f)
    end.map { |f| ["👤 #{f.name}", "friend_#{f.id}"] } # rubocop:disable Style/MultilineBlockChain

    only_me + group_options + group_member_options + other_friends
  end

  def visibility_badge(happy_thing) # rubocop:disable Metrics
    user_shares = happy_thing.happy_thing_user_shares
    group_shares = happy_thing.happy_thing_group_shares

    return nil if user_shares.empty? && group_shares.empty?

    only_self = user_shares.length == 1 && user_shares.first.friend_id == happy_thing.user_id
    return I18n.t('happy_things.badge_only_me') if only_self

    names = user_shares.reject { |s| s.friend_id == happy_thing.user_id }.map { |s| s.friend.name }
    names += group_shares.map { |s| s.group.name }
    I18n.t('happy_things.badge_shared_with', names: names.join(', '))
  end
end
