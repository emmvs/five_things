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
      'The only thing that will make you happy is being happy with who you are, and not who people think you are. - Goldie Hawn',
      'Happiness is a butterfly, which when pursued, is always beyond your grasp, but which, if you will sit down quietly, may alight upon you. - Nathaniel Hawthorne',
      'For every minute you are angry you lose sixty seconds of happiness. - Ralph Waldo Emerson',
      'Happiness is when what you think, what you say, and what you do are in harmony. - Mahatma Gandhi',
      'The most important thing is to enjoy your life—to be happy—it\'s all that matters. - Audrey Hepburn',
      'Happiness depends upon ourselves. - Aristotle',
      'There is only one happiness in this life, to love and be loved. - George Sand',
      'Count your age by friends, not years. Count your life by smiles, not tears. - John Lennon',
      'Happiness is not a goal; it is a by-product. - Eleanor Roosevelt',
      'The purpose of our lives is to be happy. - Dalai Lama',
      'Happy people plan actions, they don\'t plan results. - Dennis Waitley',
      'Be kind whenever possible. It is always possible. - Dalai Lama',
      'Happiness is the secret to all beauty. There is no beauty without happiness. - Christian Dior',
      'The happiest people don\'t have the best of everything, they just make the best of everything. - Unknown',
      'Happiness is not having what you want. It is appreciating what you have. - Unknown',
      'Do more of what makes you happy. - Unknown',
      'Happiness is a warm puppy. - Charles M. Schulz',
      'The best way to cheer yourself up is to try to cheer somebody else up. - Mark Twain',
      'Happiness is not in the mere possession of money; it lies in the joy of achievement. - Franklin D. Roosevelt',
      'Very little is needed to make a happy life. - Marcus Aurelius',
      'Happiness is letting go of what you think your life is supposed to look like. - Unknown',
      'The only joy in the world is to begin. - Cesare Pavese',
      'Be happy for this moment. This moment is your life. - Omar Khayyam',
      'Happiness is not something you postpone for the future; it is something you design for the present. - Jim Rohn',
      'Think of all the beauty still left around you and be happy. - Anne Frank',
      'Happiness often sneaks in through a door you didn\'t know you left open. - John Barrymore',
      'The key to being happy is knowing you have the power to choose what to accept and what to let go. - Dodinsky',
      'Happiness is a direction, not a place. - Sydney J. Harris'
    ]
    fake_quotes.sample
  end
end
