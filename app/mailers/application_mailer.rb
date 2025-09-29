# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'five@happythings.com'
  layout 'mailer'
end
