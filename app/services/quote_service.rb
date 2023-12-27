class QuoteService < ApplicationService
  API_URL = 'https://api.api-ninjas.com/v1/quotes'

  def initialize(category = 'happiness')
    @category = category
    @api_key = ENV['API_NINJAS_KEY']
  end

  def fetch_random_quote
    response = make_http_request(API_URL, headers: { 'X-Api-Key' => @api_key }, query: { category: @category })
    process_response(response)
  # rescue StandardError => e
  #   handle_error(e)
  end

  def self.make_http_request(endpoint)
    response = HTTParty.get("#{BASE_URL}#{endpoint}")
    return nil unless response.code == 200

    JSON.parse(response.body)
    rescue JSON::ParserError, HTTParty::Error
  end
end
