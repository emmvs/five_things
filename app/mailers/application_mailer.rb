# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base # rubocop:disable Style/Documentation
  default from: 'five@happythings.com'
  layout 'mailer'
end
