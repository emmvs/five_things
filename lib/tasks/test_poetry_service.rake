# frozen_string_literal: true

namespace :test do
  desc 'Test PoetryService'
  task poetry_service: :environment do
    result = PoetryService.get_random_poem_by_author('Emily Dickinson')
    puts result.inspect
  end
end
