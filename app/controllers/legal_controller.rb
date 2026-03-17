# frozen_string_literal: true

class LegalController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[privacy terms impressum]

  def privacy; end

  def terms; end

  def impressum; end
end
