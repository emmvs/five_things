# frozen_string_literal: true

# Overrides Devise's built-in SessionsController, which handles user login/logout.
# Devise normally requires an email + password to sign in. This controller customises
# the `create` action (i.e. the form submission when a user clicks "Log in") so that
# in development you can sign in with just an email — no password required.
# In all other environments the default Devise password-based flow (`super`) is used.
#
# Key Devise concepts used here:
#   sign_in(user)              — sets up the Warden session so the user is authenticated
#   set_flash_message!         — queues a Devise I18n flash (e.g. "Signed in successfully.")
#   after_sign_in_path_for     — the path to redirect to after login (configured in ApplicationController)
module Users
  class SessionsController < Devise::SessionsController
    before_action :disable_navbar, only: %i[new]

    def create
      return super unless passwordless_login?

      user = User.find_for_database_authentication(email: login_email)
      return sign_in_and_redirect_user(user) if user&.active_for_authentication?
      return render_passwordless_failure(user) if user

      render_passwordless_failure
    end

    private

    def passwordless_login?
      allow_passwordless? && params.dig(:user, :password).blank?
    end

    def allow_passwordless?
      Rails.env.development?
    end

    def login_email
      params.dig(:user, :email)
    end

    def sign_in_and_redirect_user(user)
      sign_in(user)
      set_flash_message!(:notice, :signed_in)
      redirect_to after_sign_in_path_for(user)
    end

    def render_passwordless_failure(user = nil)
      self.resource = resource_class.new(sign_in_params)
      alert = user ? t("devise.failure.#{user.inactive_message}") : t('sessions.user_not_found', email: login_email)
      flash.now[:alert] = alert
      render :new, status: :unprocessable_entity
    end
  end
end
