# frozen_string_literal: true

module Essence
  class SubscribersController < ApplicationController
    skip_before_action :authenticate_user!, raise: false
    before_action :disable_navbar

    rate_limit to: 5, within: 1.minute, only: :create

    def new
      @show_farewell = session.delete(:essence_farewell)
      @subscriber = EssenceSubscriber.new
    end

    def create
      subscriber = EssenceSubscriber.request_confirmation!(**subscriber_signup_params)
      send_confirmation_if_needed(subscriber)
      respond_to_create_success
    rescue ActiveRecord::RecordInvalid => e
      respond_to_create_failure(e.record)
    end

    def confirm_prompt
      @subscriber = Token.verify(params[:token], Token::CONFIRM)
      return head :not_found unless @subscriber

      @token = params[:token]
    end

    def confirm
      subscriber = Token.verify(params[:token], Token::CONFIRM)
      return head :not_found unless subscriber

      subscriber.confirm!
      redirect_to the_essence_welcome_path
    end

    def unsubscribe_prompt
      @subscriber = Token.verify(params[:token], Token::UNSUBSCRIBE)
      return head :not_found unless @subscriber

      @token = params[:token]
    end

    def unsubscribe
      subscriber = Token.verify(params[:token], Token::UNSUBSCRIBE)
      return head :not_found unless subscriber

      subscriber.unsubscribe!
      redirect_to the_essence_unsubscribed_done_path
    end

    private

    def subscriber_signup_params
      permitted = params.require(:essence_subscriber).permit(:name, :email)
      {
        email: permitted[:email],
        name: permitted[:name],
        locale: I18n.locale.to_s
      }
    end

    def send_confirmation_if_needed(subscriber)
      return if subscriber.confirmed_at.present?

      EssenceMailer.confirmation(subscriber).deliver_later
    end

    def respond_to_create_success
      farewell = t('essence.sign_up.farewell')

      if request.format.json?
        render json: { success: true, message: farewell }
        return
      end

      session[:essence_farewell] = true
      redirect_to the_essence_sign_up_path
    end

    def respond_to_create_failure(record)
      if request.format.json?
        render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
        return
      end

      @subscriber = record
      render :new, status: :unprocessable_entity
    end
  end
end
