class PoetryService < ApplicationService
  BASE_URL = 'https://poetrydb.org/'

  def call
    self.class.random_poem
  end

  def self.random_poem
    author = random_author
    return unless author

    # response = HTTParty.get("#{BASE_URL}author/#{URI.encode_www_form_component(author)}")
    endpoint = "author/#{author.gsub(' ', '%20')}"
    response = HTTParty.get("#{BASE_URL}#{endpoint}")
    return format_poem(response.parsed_response.sample) if response.ok?
  end

  private

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
    authors = JSON.parse(response.body)["authors"]
    authors.sample if authors.is_a?(Array)
  end
end
