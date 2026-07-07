# frozen_string_literal: true

module CloseFriends
  module PublisherGate
    module_function

    def publisher?(user)
      return false unless user

      publisher_ids.include?(user.id.to_s)
    end

    def publisher_ids
      ENV.fetch('CLOSE_FRIENDS_PUBLISHER_USER_IDS', '').split(',').map(&:strip)
    end
  end
end
