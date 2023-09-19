require 'httparty'
require 'uri'
class PoetryService
  BASE_URL = 'https://poetrydb.org/'

  def self.get_random_poem_by_author(author)
    # endpoint = "author/#{author}"
    # endpoint = "author/#{URI.encode(author)}"
    # endpoint = "author/#{URI.encode_www_form_component(author)}"
    endpoint = "author/#{author.gsub(' ', '%20')}"
    response = HTTParty.get("#{BASE_URL}#{endpoint}")

    return nil if response.code != 200

    poems = JSON.parse(response.body)

    if poems.is_a?(Array) && poems.first.is_a?(Hash)
      poems.sample
    else
      nil
    end
  end
end
