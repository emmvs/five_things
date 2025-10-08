# frozen_string_literal: true

class QuoteService < ApplicationService
  API_URL = 'https://api.api-ninjas.com/v1/quotes'

  def initialize(category) # rubocop:disable Lint/MissingSuper
    @category = category
    @api_key = ENV['API_NINJAS_KEY'] ||
               (defined?(Rails) && (Rails.env.development? || Rails.env.test?) ? 'FAKE_API_NINJAS_KEY' : nil)
  end

  def call
    fetch_real_quote || fetch_fake_quote
  end

  private

  def fetch_real_quote
    response = HTTParty.get(API_URL, headers: { 'X-Api-Key': @api_key }, query: { category: @category })
    format_quote(response.parsed_response.first) if response.ok?
  end

  def format_quote(quote_item)
    return nil unless quote_item && quote_item['quote'] && quote_item['author']

    "'#{quote_item['quote']}' - #{quote_item['author']}"
  end

  def fetch_fake_quote
    fake_quotes = [
      'Happiness is not something ready-made. It comes from your own actions. - Dalai Lama',
      'The only thing that will make you happy is being happy with who you are, and not who people think you are. - Goldie Hawn', # rubocop:disable Layout/LineLength
      'Happiness is a butterfly, which when pursued, is always beyond your grasp, but which, if you will sit down quietly, may alight upon you. - Nathaniel Hawthorne' # rubocop:disable Layout/LineLength
    ]
    fake_quotes.sample
  end
end
