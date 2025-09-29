# frozen_string_literal: true

require 'httparty'
require 'uri'

class ApplicationService # rubocop:disable Style/Documentation
  # Entry point for service objects
  def self.call(*args, &block)
    new(*args, &block).call
  end
end
