# frozen_string_literal: true

# ApplicationController
class ApplicationController < ActionController::Base
  before_action :should_not_render_navbar
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: %i[first_name last_name avatar emoji email_opt_in location_opt_in])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i[first_name last_name avatar emoji email_opt_in location_opt_in])
  end

  def should_not_render_navbar
    @should_render_navbar = false
  end

  def should_render_navbar
    @should_render_navbar = true
  end
end
