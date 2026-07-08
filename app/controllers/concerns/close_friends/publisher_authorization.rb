# frozen_string_literal: true

module CloseFriends
  module PublisherAuthorization
    extend ActiveSupport::Concern

    included do
      before_action :authenticate_close_friends_publisher!
    end

    private

    def authenticate_close_friends_publisher!
      return if close_friends_publisher?

      head :not_found
    end

    def close_friends_publisher?
      PublisherGate.publisher?(current_user)
    end
  end
end
