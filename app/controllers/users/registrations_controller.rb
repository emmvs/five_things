# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :disable_navbar, only: %i[new]

    def new
      super do |resource|
        if session[:guest_onboarding].present?
          resource.name = session[:guest_onboarding]['name']
          resource.emoji = session[:guest_onboarding]['emoji']
        end
      end
    end

    def create
      super do |resource|
        if resource.persisted? && session[:guest_onboarding].present?
          # Create the happy thing from the guest session
          resource.happy_things.create(
            title: session[:guest_onboarding]['happy_thing'],
            created_at: Time.current
          )
          # Clear the guest session
          session.delete(:guest_onboarding)
        end
      end
    end

    def update_resource(resource, _params)
      if updating_sensitive_info?
        resource.update_with_password(user_params)
      else
        resource.update_without_password(user_params.except(:current_password))
      end
    end

    def settings
      @user = current_user
      render 'devise/registrations/edit'
    end

    private

    def user_params
      params.require(:user).permit(:name, :avatar, :emoji, :email, :password, :password_confirmation,
                                   :current_password, :email_opt_in, :location_opt_in)
    end

    def updating_sensitive_info?
      user_params[:password].present?
    end

    def after_sign_up_path_for(_resource)
      future_root_path
    end
  end
end
