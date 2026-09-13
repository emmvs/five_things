# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EssenceSubscriber, type: :model do
  subject(:subscriber) { build(:essence_subscriber) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_inclusion_of(:locale).in_array(%w[en de sv]) }

  describe 'validations' do
    it 'rejects names with links' do
      subscriber.name = 'www.spam.com'
      expect(subscriber).not_to be_valid
    end

    it 'rejects invalid emails' do
      subscriber.email = 'not-an-email'
      expect(subscriber).not_to be_valid
    end

    it 'normalizes email to lowercase' do
      subscriber.email = '  Friend@Example.com '
      subscriber.valid?
      expect(subscriber.email).to eq('friend@example.com')
    end
  end

  describe '.request_confirmation!' do
    it 'creates a new subscriber' do
      expect do
        described_class.request_confirmation!(email: 'new@example.com', name: 'Alex', locale: 'en')
      end.to change(described_class, :count).by(1)
    end

    it 'resets an unsubscribed subscriber' do
      existing = create(:essence_subscriber, :unsubscribed, email: 'returning@example.com')

      result = described_class.request_confirmation!(
        email: 'returning@example.com',
        name: 'Alex',
        locale: 'de'
      )

      expect(result.id).to eq(existing.id)
      expect(result.unsubscribed_at).to be_nil
      expect(result.confirmed_at).to be_nil
      expect(result.locale).to eq('de')
    end
  end

  describe '#confirm!' do
    it 'sets confirmed_at once' do
      subscriber.save!
      subscriber.confirm!
      first_confirmed_at = subscriber.confirmed_at

      subscriber.confirm!

      expect(subscriber.reload.confirmed_at).to eq(first_confirmed_at)
    end
  end

  describe '#unsubscribe!' do
    it 'sets unsubscribed_at once' do
      subscriber = create(:essence_subscriber, :confirmed)
      subscriber.unsubscribe!
      first_unsubscribed_at = subscriber.unsubscribed_at

      subscriber.unsubscribe!

      expect(subscriber.reload.unsubscribed_at).to eq(first_unsubscribed_at)
    end
  end
end
