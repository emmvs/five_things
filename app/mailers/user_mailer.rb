# frozen_string_literal: true

class UserMailer < ApplicationMailer # rubocop:disable Style/Documentation
  def happy_things_notification(user)
    @user = user
    mail(to: @user.email, subject: 'Happy Things incoming!🎁')
  end

  def email_confirmation(user)
    @user = user
    @confirmation_url = user_confirmation_url(confirmation_token: @user.confirmation_token)

    mail(to: @user.email, subject: 'Confirm your email address')
  end
end
