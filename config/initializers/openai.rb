# frozen_string_literal: true

OpenAI.configure do |config|
  config.access_token = ENV.fetch('OPENAI_API_KEY')
end
