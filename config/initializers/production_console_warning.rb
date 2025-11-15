# frozen_string_literal: true

# Security warning when accessing production console
if defined?(Rails::Console) && Rails.env.production?
  puts "\n"
  puts '=' * 80
  puts '⚠️  WARNING: PRODUCTION CONSOLE'.center(80)
  puts '=' * 80
  puts 'You are accessing PRODUCTION data containing real user information.'.center(80)
  puts 'This access is logged and monitored.'.center(80)
  puts ''
  puts 'GDPR Compliance Reminders:'.center(80)
  puts '- Only access data when absolutely necessary'.center(80)
  puts '- Do not copy or share personal data'.center(80)
  puts '- All access must be justified and documented'.center(80)
  puts '- Users have the right to know who accessed their data'.center(80)
  puts '=' * 80
  puts "\n"

  # Log console access
  Rails.logger.warn("PRODUCTION CONSOLE ACCESS: User opened Rails console at #{Time.current}")
end

# Monkey patch to warn when accessing sensitive models in production console
if defined?(Rails::Console) && Rails.env.production?
  [User, HappyThing, Comment, Friendship].each do |model|
    model.class_eval do
      class << self
        alias_method :original_all, :all
        alias_method :original_find, :find
        alias_method :original_find_by, :find_by
        alias_method :original_where, :where

        def all
          warn_sensitive_access("#{name}.all")
          original_all
        end

        def find(*args)
          warn_sensitive_access("#{name}.find(#{args.first})")
          original_find(*args)
        end

        def find_by(*args)
          warn_sensitive_access("#{name}.find_by(...)")
          original_find_by(*args)
        end

        def where(*args)
          warn_sensitive_access("#{name}.where(...)")
          original_where(*args)
        end

        private

        def warn_sensitive_access(query)
          puts "\n⚠️  ACCESSING SENSITIVE DATA: #{query}"
          puts "This access is being logged for GDPR compliance.\n"
          Rails.logger.warn("SENSITIVE DATA ACCESS: #{query} at #{Time.current}")
        end
      end
    end
  end
end
