# frozen_string_literal: true

class TheEssenceController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  before_action :disable_navbar

  def show; end
end
