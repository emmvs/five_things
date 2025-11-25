# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    before_action :disable_navbar, only: %i[new]

    def create
      if Rails.env.development? && params[:user][:password].blank?
        # Passwordless login for development
        user = User.find_by(email: params[:user][:email])

        if user
          sign_in(user)
          set_flash_message!(:notice, :signed_in)
          redirect_to after_sign_in_path_for(user)
        else
          flash[:alert] = "User with email #{params[:user][:email]} not found"
          render :new, status: :unprocessable_entity
        end
      else
        # Normal password-based login
        super
      end
    end
  end
end
