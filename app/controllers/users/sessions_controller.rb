# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :disable_navbar, only: %i[new]
end
