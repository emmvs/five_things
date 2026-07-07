# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CloseFriendsIssue, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  subject(:issue) { build(:close_friends_issue) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:body) }

  describe '#publish!' do
    it 'sets published_at for a draft' do
      issue.save!
      issue.publish!
      expect(issue.published_at).to be_present
    end

    it 'uses the publisher timezone when setting published_at' do
      publisher = create(:user, timezone: 'Asia/Tokyo')
      issue = create(:close_friends_issue, created_by: publisher)

      Time.use_zone('UTC') do
        travel_to Time.utc(2026, 1, 15, 14, 0, 0) do
          issue.publish!
        end
      end

      expect(issue.published_at.in_time_zone('Asia/Tokyo').hour).to eq(23)
    end
  end

  describe '#mark_sent!' do
    it 'sets sent_at for a published issue' do
      issue = create(:close_friends_issue, :published)
      issue.mark_sent!
      expect(issue.sent_at).to be_present
    end
  end

  describe '#sendable?' do
    it 'is true when published and not sent' do
      issue = build(:close_friends_issue, :published)
      expect(issue).to be_sendable
    end

    it 'is false for drafts' do
      expect(issue).not_to be_sendable
    end
  end
end
