# frozen_string_literal: true

module FriendshipsHelper
  def can_add_as_friend?(current_user, potential_friend)
    return false if current_user.friends.include?(potential_friend)

    sent_request = current_user.friendships.find_by(friend_id: potential_friend.id)
    received_request = current_user.received_friend_requests.find_by(user_id: potential_friend.id)

    !(sent_request || received_request)
  end
end
