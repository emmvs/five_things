# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    before_action :disable_navbar, only: %i[new]
  end
end
