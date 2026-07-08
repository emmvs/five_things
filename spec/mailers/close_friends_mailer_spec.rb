# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CloseFriendsMailer, type: :mailer do
  describe '#issue' do
    let(:subscriber) { create(:close_friends_subscriber, :approved) }
    let(:issue) { create(:close_friends_issue, title: 'Summer update') }
    let(:mail) { described_class.issue(subscriber, issue) }

    it 'uses a Close Friends subject line with the issue title' do
      expect(mail.subject).to eq(I18n.t('close_friends.mailer.issue_subject', title: issue.title))
    end

    it 'includes the issue title in the body' do
      expect(mail.body.encoded).to include(issue.title)
    end
  end
end
