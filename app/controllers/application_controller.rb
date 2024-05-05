# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_should_render_navbar
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :avatar, :emoji, :email_opt_in, :location_opt_in])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :avatar, :emoji, :email_opt_in, :location_opt_in])
  end

  def set_should_render_navbar
    @should_render_navbar = false
  end
end
