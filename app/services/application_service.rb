require 'httparty'

class ApplicationService
  def self.make_http_request(endpoint, options = {})
    options = { headers: headers, query: query }
    HTTParty.get(url, options)
  end

  def self.process_response(response)
    return JSON.parse(response.body) if response.success?

    handle_http_error(response)
  end

  def self.handle_http_error(response)
    raise "HTTP Error: #{response.code} - #{response.message}"
  end

  def self.handle_error(error)
    # Implement error handling or logging here
    raise "An error occurred: #{error.message}"
  end
end
