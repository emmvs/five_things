# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CloseFriendsSubscriber, type: :model do
  subject(:subscriber) { build(:close_friends_subscriber) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

  it 'rejects invalid emails' do
    subscriber.email = 'not-an-email'
    expect(subscriber).not_to be_valid
  end

  it 'rejects short names' do
    subscriber.name = 'Al'
    expect(subscriber).not_to be_valid
  end

  it 'rejects names with links' do
    subscriber.name = 'www.spam.com'
    expect(subscriber).not_to be_valid
  end

  describe '.request_confirmation!' do
    it 'creates a new subscriber' do
      expect do
        described_class.request_confirmation!(email: 'new@example.com', name: 'New Friend')
      end.to change(described_class, :count).by(1)
    end

    it 'resets an unsubscribed subscriber' do
      subscriber = create(:close_friends_subscriber, :unsubscribed, email: 'again@example.com')

      described_class.request_confirmation!(email: 'again@example.com', name: 'Again Friend')

      subscriber.reload
      expect(subscriber.name).to eq('Again Friend')
      expect(subscriber.unsubscribed_at).to be_nil
      expect(subscriber.confirmed_at).to be_nil
    end
  end

  describe 'scopes' do
    it 'returns deliverable subscribers' do
      approved = create(:close_friends_subscriber, :approved)
      create(:close_friends_subscriber, :confirmed)

      expect(described_class.deliverable).to contain_exactly(approved)
    end
  end
end
