# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      user = User.from_omniauth(auth)

      if user.persisted?
        sign_out_all_scopes
        flash[:success] = t 'devise.omniauth_callbacks.success', kind: 'Google'
        sign_in_and_redirect user, event: :authentication
      else
        flash[:alert] = 'Authentication failed. Please try again.'
        redirect_to new_user_session_path
      end
    rescue StandardError => e
      Rails.logger.error "OAuth failed: #{e.message}"
      flash[:alert] = 'Authentication failed. Please try again.'
      redirect_to new_user_session_path
    end

    protected

    def after_omniauth_failure_path_for(_scope)
      new_user_session_path
    end

    def after_sign_in_path_for(resource_or_scope)
      stored_location_for(resource_or_scope) || root_path
    end

    private

    def auth
      @auth ||= request.env['omniauth.auth']
    end
  end
end
