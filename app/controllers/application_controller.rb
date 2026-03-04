# frozen_string_literal: true

# ApplicationController
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  before_action :set_timezone
  before_action :authenticate_user!, unless: :public_controller?
  before_action :set_navbar_default
  helper_method :render_navbar?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: %i[name emoji email_opt_in location_opt_in locale])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i[name emoji email_opt_in location_opt_in locale])
  end

  def after_sign_in_path_for(_resource)
    authenticated_root_path
  end

  private

  def set_navbar_default
    @render_navbar = user_signed_in?
  end

  def render_navbar?
    @render_navbar
  end

  def disable_navbar
    @render_navbar = false
  end

  def set_locale
    I18n.locale = current_user&.locale || I18n.default_locale
  end

  def set_timezone
    Time.zone = current_user.timezone if current_user
  end

  def public_controller?
    controller_name.in?(%w[pages])
  end
end
