# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :disable_navbar, only: %i[home]
  def home; end
end
