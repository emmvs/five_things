require 'httparty'

class PoetryService
  BASE_URL = 'https://poetrydb.org/'

  def self.get_random_poem_by_dickinson
    endpoint = "author/dickinson"
    response = HTTParty.get("#{BASE_URL}#{endpoint}")

    return nil if response.code != 200

    poems = JSON.parse(response.body)
    poems.sample
  end
end
