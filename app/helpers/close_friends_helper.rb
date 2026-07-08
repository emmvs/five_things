# frozen_string_literal: true

module CloseFriendsHelper
  def close_friends_publisher?
    CloseFriends::PublisherGate.publisher?(current_user)
  end

  def issue_status_key(issue)
    return 'draft' if issue.draft?
    return 'published' if issue.published?

    'sent'
  end
end
