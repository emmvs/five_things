# frozen_string_literal: true

class CloseFriendsIssue < ApplicationRecord
  belongs_to :created_by, class_name: 'User', optional: true

  validates :title, presence: true, length: { maximum: 200 }
  validates :body, presence: true, length: { maximum: 50_000 }

  def draft?
    published_at.nil?
  end

  def published?
    published_at.present? && sent_at.nil?
  end

  def sent?
    sent_at.present?
  end

  def publish!
    update!(published_at: publisher_time_now) if draft?
  end

  def mark_sent!
    update!(sent_at: publisher_time_now) if sendable?
  end

  def sendable?
    published_at.present? && sent_at.nil?
  end

  private

  def publisher_time_now
    in_publisher_time_zone { Time.zone.now }
  end

  def in_publisher_time_zone(&)
    timezone = created_by&.timezone.presence
    return yield unless timezone

    Time.use_zone(timezone, &)
  end
end
