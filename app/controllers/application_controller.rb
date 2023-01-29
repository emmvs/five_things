# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  before_action :set_should_render_navbar
  
  def set_should_render_navbar
    @should_render_navbar = false
  end
end
