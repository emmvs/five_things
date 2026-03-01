# frozen_string_literal: true

module FriendshipsHelper
  def can_add_as_friend?(current_user, potential_friend)
    !current_user.friends.include?(potential_friend) &&
      !current_user.friendships.exists?(friend_id: potential_friend.id)
  end

  def filter_users_by_query(users, query)
    return users if query.blank?

    users.select { |user| matches_query?(user, query.downcase) }
  end

  private

  def matches_query?(user, query_downcase)
    [user.name, user.username, user.email]
      .compact
      .any? { |field| field.downcase.include?(query_downcase) }
  end
end
