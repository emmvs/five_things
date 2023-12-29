class ApplicationController < ActionController::Base
  before_action :set_should_render_navbar
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :avatar, :emoji])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :avatar, :emoji])
  end

  def set_should_render_navbar
    @should_render_navbar = false
  end
end
