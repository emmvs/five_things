# frozen_string_literal: true

# Low-level HTTP client for Oura API
# Handles authentication, requests, and response parsing
class OuraClient
  BASE_URL = 'https://api.ouraring.com'
  API_VERSION = 'v2'

  class OuraError < StandardError; end
  class AuthenticationError < OuraError; end
  class RateLimitError < OuraError; end
  class NotFoundError < OuraError; end

  def initialize(access_token:)
    @access_token = access_token
  end

  # GET request to Oura API
  def get(endpoint, params: {})
    url = build_url(endpoint)

    response = HTTParty.get(
      url,
      query: params,
      headers:
    )

    handle_response(response)
  rescue HTTParty::Error => e
    Rails.logger.error("Oura HTTP error: #{e.message}")
    raise OuraError, "HTTP request failed: #{e.message}"
  end

  # Refresh OAuth tokens
  def self.refresh_token(refresh_token:, client_id:, client_secret:)
    response = HTTParty.post(
      "#{BASE_URL}/oauth/token",
      body: {
        grant_type: 'refresh_token',
        refresh_token:,
        client_id:,
        client_secret:
      },
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
    )

    if response.success?
      response.parsed_response
    else
      Rails.logger.error("Token refresh failed: #{response.code} - #{response.body}")
      raise AuthenticationError, "Failed to refresh token: #{response.body}"
    end
  end

  private

  def build_url(endpoint)
    # Remove leading slash if present
    endpoint = endpoint.delete_prefix('/')
    "#{BASE_URL}/#{API_VERSION}/#{endpoint}"
  end

  def headers
    {
      'Authorization' => "Bearer #{@access_token}",
      'Content-Type' => 'application/json'
    }
  end

  def handle_response(response)
    case response.code
    when 200..299
      response.parsed_response
    when 401
      Rails.logger.error("Oura authentication failed: #{response.body}")
      raise AuthenticationError, 'Invalid or expired access token'
    when 404
      raise NotFoundError, 'Resource not found'
    when 429
      retry_after = response.headers['Retry-After'] || 60
      Rails.logger.warn("Oura rate limit hit, retry after #{retry_after}s")
      raise RateLimitError, "Rate limit exceeded, retry after #{retry_after} seconds"
    else
      Rails.logger.error("Oura API error: #{response.code} - #{response.body}")
      raise OuraError, "API request failed with status #{response.code}"
    end
  end
end
