# frozen_string_literal: true

require 'httparty'
require 'uri'

class ApplicationService
  # Entry point for service objects
  def self.call(*, &)
    new(*, &).call
  end
end
