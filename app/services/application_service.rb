require 'httparty'
require 'uri'

class ApplicationService
  # Entry point for service objects
  def self.call(*args, &block)
    new(*args, &block).call
  end
end
