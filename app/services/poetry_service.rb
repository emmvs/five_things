require 'httparty'
require 'uri'
class PoetryService
  BASE_URL = 'https://poetrydb.org/'

  def self.get_random_author
    response = make_http_request("authors")
    return nil unless response

    authors = response["authors"]
    authors.sample
  end

  def self.get_random_poem_by_author(author)
    endpoint = "author/#{author.gsub(' ', '%20')}"
    response = HTTParty.get("#{BASE_URL}#{endpoint}")

    return nil if response.code != 200

    poems = JSON.parse(response.body)
    poems.is_a?(Array) ? poems.sample : nil
  end

  def self.get_random_poem
    author = get_random_author
    return nil unless author

    get_random_poem_by_author(author)
  end

  private

  def self.make_http_request(endpoint)
    response = HTTParty.get("#{BASE_URL}#{endpoint}")
    return nil unless response.code == 200

    JSON.parse(response.body)
    rescue JSON::ParserError, HTTParty::Error
  end
end
