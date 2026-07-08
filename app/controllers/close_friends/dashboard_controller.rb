# frozen_string_literal: true

module CloseFriends
  class DashboardController < ApplicationController
    include PublisherAuthorization

    def index
      @deliverable_count = CloseFriendsSubscriber.deliverable.count
      @pending_subscribers = CloseFriendsSubscriber.pending_approval.order(created_at: :desc)
      @issues = CloseFriendsIssue.order(created_at: :desc)
    end
  end
end
