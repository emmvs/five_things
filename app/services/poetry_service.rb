# frozen_string_literal: true

class PoetryService < ApplicationService # rubocop:disable Style/Documentation
  BASE_URL = ENV.fetch('POETRY_DB_URL', 'FAKE_POETRY_DB_URL')

  def call
    fetch_real_poem || fetch_fake_poem
  rescue JSON::ParserError
    fetch_fake_poem
  end

  def self.random_poem
    response = HTTParty.get("#{BASE_URL}authors")
    return nil unless response.ok?

    begin
      authors = JSON.parse(response.body)['authors']

      return nil unless authors.is_a?(Array) && authors.any?

      authors.sample
    rescue JSON::ParserError
      nil
    end
  end

  def self.format_poem(poem)
    return nil unless poem && poem['title'] && poem['author'] && poem['lines']

    {
      title: poem['title'],
      author: poem['author'],
      lines: poem['lines'].is_a?(Array) ? poem['lines'] : poem['lines'].split("\n")
    }
  end

  def self.random_author
    response = HTTParty.get("#{BASE_URL}authors")
    return nil unless response.ok?

    authors = JSON.parse(response.body)['authors']
    authors.sample if authors.is_a?(Array)
  end

  def self.fake_poem # rubocop:disable Metrics/MethodLength
    {
      title: 'Journey of the Magi',
      author: 'T.S. Eliot',
      lines: [
        'A cold coming we had of it',
        'Just the worst time of the year',
        'For a journey, and such a long journey',
        'The ways deep and the weather sharp',
        'The very dead of winter'
      ]
    }
  end

  private

  def fetch_real_poem
    self.class.random_poem
  end

  def fetch_fake_poem
    self.class.fake_poem
  end
end
