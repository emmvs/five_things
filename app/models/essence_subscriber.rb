# frozen_string_literal: true

class EssenceSubscriber < ApplicationRecord
  NAME_FORMAT = %r{http|https|www|<script.*?>|</script>}i
  LOCALES = %w[en de sv].freeze

  validates :name, presence: true,
                   length: { in: 3..30 },
                   format: { without: NAME_FORMAT }

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    length: { in: 3..255 }

  validates :locale, inclusion: { in: LOCALES }

  before_validation :normalize_name
  before_validation :normalize_email

  scope :pending_confirmation, -> { where(confirmed_at: nil, unsubscribed_at: nil) }
  scope :deliverable, -> { where.not(confirmed_at: nil).where(unsubscribed_at: nil) }

  def confirm!
    update!(confirmed_at: Time.current) if confirmed_at.nil?
  end

  def unsubscribe!
    update!(unsubscribed_at: Time.current) if unsubscribed_at.nil?
  end

  def self.request_confirmation!(email:, name:, locale:)
    normalized_email = email.to_s.strip.downcase
    subscriber = find_by(email: normalized_email)
    attrs = { email: normalized_email, name: name.to_s.strip, locale: locale.to_s }

    return create!(attrs) if subscriber.nil?

    handle_existing_subscriber!(subscriber, attrs)
  end

  def self.handle_existing_subscriber!(subscriber, attrs)
    reset_unsubscribed!(subscriber) if subscriber.unsubscribed_at.present?
    subscriber.assign_attributes(name: attrs[:name], locale: attrs[:locale])
    subscriber.save!
    subscriber
  end

  def self.reset_unsubscribed!(subscriber)
    subscriber.assign_attributes(confirmed_at: nil, unsubscribed_at: nil)
  end

  private

  def normalize_name
    self.name = name.to_s.strip.presence
  end

  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
