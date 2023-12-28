class QuoteService < ApplicationService
  API_URL = 'https://api.api-ninjas.com/v1/quotes'

  def initialize(category)
    @category = category
    @api_key = ENV.fetch('API_NINJAS_KEY')
  end

  def call
    response = HTTParty.get(API_URL, headers: { 'X-Api-Key': @api_key }, query: { category: @category })
    return format_quote(response.parsed_response.first) if response.ok?
  end

  private

  def format_quote(quote_item)
    return nil unless quote_item && quote_item["quote"] && quote_item["author"]

    "'#{quote_item['quote']}' - #{quote_item['author']}"
  end
end
