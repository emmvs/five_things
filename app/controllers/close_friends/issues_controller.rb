# frozen_string_literal: true

module CloseFriends
  class IssuesController < ApplicationController
    include PublisherAuthorization

    skip_before_action :authenticate_close_friends_publisher!, only: :show
    before_action :disable_navbar, only: :show
    before_action :set_issue, only: %i[show edit update publish send_issue]
    before_action :ensure_published!, only: :show
    before_action :ensure_editable!, only: %i[edit update]
    before_action :ensure_sendable!, only: :send_issue

    def show; end

    def new
      @issue = CloseFriendsIssue.new
    end

    def create
      @issue = CloseFriendsIssue.new(issue_params.merge(created_by: current_user))
      return render :new, status: :unprocessable_entity unless @issue.save

      redirect_to edit_close_friends_issue_path(@issue), notice: t('close_friends.issues.created')
    end

    def edit; end

    def update
      return render :edit, status: :unprocessable_entity unless @issue.update(issue_params)

      redirect_to edit_close_friends_issue_path(@issue), notice: t('close_friends.issues.updated')
    end

    def publish
      @issue.publish!
      redirect_to close_friends_issue_path(@issue), notice: t('close_friends.issues.published')
    end

    def send_issue
      deliver_issue_to_subscribers
      @issue.mark_sent!
      redirect_to close_friends_dashboard_path, notice: t('close_friends.issues.sent')
    end

    private

    def set_issue
      @issue = CloseFriendsIssue.find(params[:id])
    end

    def ensure_published!
      head :not_found if @issue.draft?
    end

    def ensure_editable!
      head :not_found if @issue.sent?
    end

    def ensure_sendable!
      head :not_found unless @issue.sendable?
    end

    def issue_params
      params.require(:close_friends_issue).permit(:title, :body)
    end

    def deliver_issue_to_subscribers
      CloseFriendsSubscriber.deliverable.find_each do |subscriber|
        CloseFriendsMailer.issue(subscriber, @issue).deliver_later
      end
    end
  end
end
