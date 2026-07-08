# frozen_string_literal: true

module CloseFriends
  class JoinsController < ApplicationController
    include PublisherAuthorization

    skip_before_action :authenticate_close_friends_publisher!
    before_action :disable_navbar

    def show
      return redirect_to close_friends_dashboard_path if close_friends_publisher?

      @subscriber = CloseFriendsSubscriber.new
    end
  end
end
