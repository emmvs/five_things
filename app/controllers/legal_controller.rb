# frozen_string_literal: true

class LegalController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[privacy terms]

  def privacy; end

  def terms; end
end
