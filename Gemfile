source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Ruby version
ruby '3.1.2'

# Core Rails gems
gem 'bootsnap', require: false # Reduces boot times through caching
gem 'httparty' # For API calls
gem 'importmap-rails' # Importmap support for Rails
gem 'jbuilder'
gem 'pg' # PostgreSQL as the database for Active Record
gem 'puma', '~> 5.0' # Use Puma as the app server
gem 'rails', '~> 7.0.6'
gem 'sprockets-rails' # Asset pipeline
gem 'stimulus-rails' # Hotwire's Stimulus framework for Rails
gem 'turbo-rails' # Hotwire's Turbo library for Rails

# Redis and Kredis for caching & Action Cable
gem 'redis', '~> 4.0'
# gem 'kredis'

# Front-end
gem 'autoprefixer-rails' # Parses CSS and adds vendor prefixes
gem 'bootstrap', '~> 5.2' # Bootstrap for styling
gem 'font-awesome-rails' # Font Awesome icons
gem 'sassc-rails' # Use SCSS for stylesheets

# Devise for authentication
gem 'devise', '~> 4.8'

# Pagination with kaminari
gem 'kaminari'

# Simple Form for forms
gem 'simple_calendar', '~> 2.4'
gem 'simple_form', '~> 5.1'

# Cloudinary for image and video storage
gem 'cloudinary'

# APIs & Special Gems
gem 'moonphases'
gem 'ruby-openai'

# Action Mailer
gem 'letter_opener'

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
  gem 'shoulda-matchers' # Additional matchers for RSpec
end

group :development do
  gem 'web-console' # Rails console for the browser
  # gem 'spring' # Speeds up development by keeping app running in the background
  # gem 'rack-mini-profiler' # Displays speed badge for performance profiling
end

group :test do
  gem 'capybara' # Capybara for integration testing
  gem 'selenium-webdriver' # WebDriver for browsers
  gem 'webdrivers' # Auto-updates webdrivers
end

# Optional gems for specific features
# gem 'bcrypt', '~> 3.1.7' # Use Active Model has_secure_password
# gem 'image_processing', '~> 1.2' # Use Active Storage variants for image processing
# gem 'tzinfo-data', platforms: %i[ mingw mswin x64_mingw jruby ] # Timezone data
