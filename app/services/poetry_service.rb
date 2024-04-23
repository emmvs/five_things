class PoetryService < ApplicationService
  BASE_URL = ENV['POETRY_DB_URL'] || 'https://poetrydb.org/'.freeze

  def call
    fetch_real_poem || fetch_fake_poem
  end

  private

  def fetch_real_poem
    self.class.random_poem
  end

  def self.random_poem
    response = HTTParty.get("#{BASE_URL}authors")
    return nil unless response.ok?
  
    begin
      authors = JSON.parse(response.body)["authors"]
  
      if authors.is_a?(Array) && authors.any?
        chosen_author = authors.sample
        return chosen_author
      else
        return nil
      end

    rescue JSON::ParserError
      return nil
    end
  end

  def self.format_poem(poem)
    return nil unless poem && poem["title"] && poem["author"] && poem["lines"]

    {
      title: poem["title"],
      author: poem["author"],
      lines: poem["lines"].is_a?(Array) ? poem["lines"] : poem["lines"].split("\n")
    }
  end

  def self.random_author
    response = HTTParty.get("#{BASE_URL}authors")
    return nil unless response.ok?

    authors = JSON.parse(response.body)["authors"]
    authors.sample if authors.is_a?(Array)
  end

  def fetch_fake_poem
    self.class.fake_poem
  end

  def self.fake_poem
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
end
