module FriendshipsHelper
  def can_add_as_friend?(current_user, potential_friend)
    return false if current_user.friends.include?(potential_friend)

    direct_friendship = current_user.friendships.find_by(friend_id: potential_friend.id)
    inverse_friendship = potential_friend.friendships.find_by(user_id: current_user.id)

    !(direct_friendship || inverse_friendship)
  end
end
