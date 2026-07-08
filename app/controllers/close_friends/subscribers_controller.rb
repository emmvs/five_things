# frozen_string_literal: true

module CloseFriends
  class SubscribersController < ApplicationController
    include PublisherAuthorization

    skip_before_action :authenticate_close_friends_publisher!, only: %i[create confirm unsubscribe]
    before_action :disable_navbar, only: %i[create confirm unsubscribe]

    def create
      subscriber = CloseFriendsSubscriber.request_confirmation!(**subscriber_signup_params)
      send_confirmation_if_needed(subscriber)
      redirect_to close_friends_root_path, notice: t('close_friends.subscribers.signup_notice')
    rescue ActiveRecord::RecordInvalid => e
      @subscriber = e.record
      render_join_form_with_errors
    end

    def confirm
      subscriber = Token.verify(params[:token], Token::CONFIRM)
      return head :not_found unless subscriber

      subscriber.confirm!
      render :confirmed
    end

    def unsubscribe
      subscriber = Token.verify(params[:token], Token::UNSUBSCRIBE)
      return head :not_found unless subscriber

      subscriber.unsubscribe!
      render :unsubscribed
    end

    def approve
      subscriber = CloseFriendsSubscriber.pending_approval.find(params[:id])
      subscriber.approve!
      redirect_to close_friends_dashboard_path, notice: t('close_friends.subscribers.approved')
    end

    def reject
      subscriber = CloseFriendsSubscriber.pending_approval.find(params[:id])
      subscriber.destroy!
      redirect_to close_friends_dashboard_path, notice: t('close_friends.subscribers.rejected')
    end

    private

    def subscriber_signup_params
      permitted = params.require(:close_friends_subscriber).permit(:email, :name)
      { email: permitted[:email], name: permitted[:name] }
    end

    def send_confirmation_if_needed(subscriber)
      return if subscriber.confirmed_at.present?

      CloseFriendsMailer.confirmation(subscriber).deliver_later
    end

    def render_join_form_with_errors
      @subscriber ||= CloseFriendsSubscriber.new(subscriber_signup_params)
      render 'close_friends/joins/show', status: :unprocessable_entity
    end
  end
end
