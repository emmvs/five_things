# frozen_string_literal: true

class CloseFriendsSubscriber < ApplicationRecord
  NAME_FORMAT = %r{http|https|www|<script.*?>|</script>}i

  validates :name, presence: true,
                   length: { in: 3..30, message: I18n.t('errors.models.user.name.length') },
                   format: { without: NAME_FORMAT, message: I18n.t('errors.models.user.name.invalid') }

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    length: { in: 3..255 }

  before_validation :normalize_name
  before_validation :normalize_email

  scope :pending_confirmation, -> { where(confirmed_at: nil, unsubscribed_at: nil) }
  scope :pending_approval, lambda {
    where.not(confirmed_at: nil).where(approved_at: nil, unsubscribed_at: nil)
  }
  scope :deliverable, -> { where.not(approved_at: nil).where(unsubscribed_at: nil) }

  def confirm!
    update!(confirmed_at: Time.current) if confirmed_at.nil?
  end

  def approve!
    update!(approved_at: Time.current) if approved_at.nil? && confirmed_at.present?
  end

  def unsubscribe!
    update!(unsubscribed_at: Time.current) if unsubscribed_at.nil?
  end

  def self.request_confirmation!(email:, name:)
    normalized_email = email.to_s.strip.downcase
    subscriber = find_by(email: normalized_email)
    attrs = { email: normalized_email, name: name.to_s.strip }

    return create!(attrs) if subscriber.nil?

    handle_existing_subscriber!(subscriber)
    subscriber.assign_attributes(name: attrs[:name])
    subscriber.save!
    subscriber
  end

  def self.handle_existing_subscriber!(subscriber)
    reset_unsubscribed!(subscriber) if subscriber.unsubscribed_at.present?
    subscriber.save! if subscriber.changed?
  end

  def self.reset_unsubscribed!(subscriber)
    subscriber.assign_attributes(confirmed_at: nil, approved_at: nil, unsubscribed_at: nil)
  end

  private

  def normalize_name
    self.name = name.to_s.strip.presence
  end

  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
