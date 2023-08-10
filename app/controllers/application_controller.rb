# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  before_action :set_should_render_navbar

  # Add Sleep to see changes
  # before_action -> { sleep 3 }

  def set_should_render_navbar
    @should_render_navbar = false
  end
end
