# frozen_string_literal: true

# ApplicationController
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, unless: :public_controller?
  before_action :set_navbar_default
  helper_method :render_navbar?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: %i[first_name last_name avatar emoji email_opt_in location_opt_in])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i[first_name last_name avatar emoji email_opt_in location_opt_in])
  end

  private

  def set_navbar_default
    @render_navbar = true
  end

  def render_navbar?
    @render_navbar
  end

  def disable_navbar
    @render_navbar = false
  end

  def public_controller?
    controller_name.in?(%w[pages])
  end
end
