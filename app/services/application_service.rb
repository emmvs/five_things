# frozen_string_literal: true

require 'httparty'
require 'uri'

# rubocop:disable Style/ArgumentsForwarding
class ApplicationService
  # Entry point for service objects
  def self.call(*args, &block)
    new(*args, &block).call
  end
end
# rubocop:enable Style/ArgumentsForwarding
