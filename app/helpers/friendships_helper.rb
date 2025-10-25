# frozen_string_literal: true

module FriendshipsHelper
  def can_add_as_friend?(current_user, potential_friend)
    return false if current_user.friends.include?(potential_friend)

    sent_request = current_user.friendships.find_by(friend_id: potential_friend.id)
    received_request = current_user.received_friend_requests.find_by(user_id: potential_friend.id)

    !(sent_request || received_request)
  end

  def filter_users_by_query(users, query)
    return users if query.blank?

    query_downcase = query.downcase
    users.select do |user|
      matches_query?(user, query_downcase)
    end
  end

  private

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def matches_query?(user, query_downcase)
    user.first_name&.downcase&.include?(query_downcase) ||
      user.last_name&.downcase&.include?(query_downcase) ||
      user.username&.downcase&.include?(query_downcase) ||
      user.email&.downcase&.include?(query_downcase)
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
