# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Ruby version
ruby '3.4.4'

# Core Rails gems
gem 'bootsnap', require: false # Reduces boot times through caching
gem 'httparty' # For API calls
gem 'importmap-rails', '~> 2.0'
gem 'jbuilder', '~> 2.13'
gem 'pg' # PostgreSQL as the database for Active Record
gem 'puma', '~> 6.4'
gem 'rails', '~> 8.0.3'
gem 'sprockets-rails' # Asset pipeline
gem 'stimulus-rails', '~> 1.3'
gem 'turbo-rails', '~> 2.0'

# Core Ruby / Standard Library Extensions
gem 'csv', '~> 3.3'
gem 'observer'

# Redis for caching & Action Cable
gem 'redis', '~> 5.0'

# Front-end
gem 'autoprefixer-rails' # Parses CSS and adds vendor prefixes
gem 'bootstrap', '~> 5.2' # Bootstrap for styling
gem 'font-awesome-rails' # Font Awesome icons
gem 'sassc-rails' # Use SCSS for stylesheets

# Devise for authentication
gem 'devise', '~> 4.8'

# OAauth Providers
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'

# Pagination with kaminari
gem 'kaminari'

# Simple Form for forms
gem 'simple_calendar', '~> 2.4'
gem 'simple_form', '~> 5.1'

# Cloudinary for image and video storage
gem 'cloudinary'

# Maps
gem 'geocoder'

# APIs & Special Gems
gem 'moonphases'
gem 'ostruct'

# Testing suite
group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails' # Load environment variables from .env
  gem 'factory_bot_rails' # Factory Bot for test data
  gem 'faker'
  gem 'pry-byebug' # Pry for debugging
  gem 'rails-controller-testing'
  gem 'rspec-rails' # RSpec for testing
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'shoulda-matchers' # Additional matchers for RSpec
end

group :development do
  gem 'annotaterb' # Annotate models with schema (Rails 8 compatible fork)
  gem 'brakeman' # Static analysis security vulnerability scanner for Ruby on Rails applications
  gem 'letter_opener' # Preview emails in the browser instead of sending them
  gem 'web-console' # Rails console for the browser
end

group :test do
  gem 'capybara' # Capybara for integration testing
  gem 'selenium-webdriver' # WebDriver for browsers
end
