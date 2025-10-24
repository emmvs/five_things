# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HappyThing, type: :model do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  describe 'Validations' do
    it { should validate_presence_of(:title) }
  end

  describe 'Associations' do
    it { should belong_to(:user) }
  end

  describe 'Scope' do
    it 'orders by created_at in descending order' do
      user = create(:user)
      happy_thing1 = create(:happy_thing, user:, created_at: 2.days.ago)
      happy_thing2 = create(:happy_thing, user:, created_at: 1.day.ago)

      expect(described_class.order(created_at: :desc)).to eq([happy_thing2, happy_thing1])
    end
  end

  describe 'Methods' do
    it 'sets start_time depending on users timezone' do
      user = create(:user, timezone: 'Eastern Time (US & Canada)')
      Time.zone = user.timezone
      server_time = Time.utc(2025, 9, 1, 2, 0, 0)

      travel_to server_time do
        happy_thing = create(:happy_thing, user:, start_time: Time.zone.now)

        expect(happy_thing.start_time.to_date).to eq(Date.new(2025, 8, 31))
        expect(happy_thing.created_at.utc.hour).to eq(2)
      end
    end
  end

  describe 'Callbacks' do
    context 'when a user adds 5 happy things in a day' do
      it 'sends an email to each of their friends' do
        user = create(:user)
        friends = create_list(:user, 3)

        friends.each do |friend|
          create(:friendship, user:, friend:)
          create(:friendship, user: friend, friend: user)
        end

        perform_enqueued_jobs do
          create_list(:happy_thing, 5, user:)
        end

        delivered_emails = ActionMailer::Base.deliveries.map(&:to).flatten

        friends.each do |friend|
          expect(delivered_emails).to include(friend.email)
        end
      end
    end
  end

  describe 'Mailers' do
    before { clear_enqueued_jobs }

    it 'sends an email to each of their friends but not to non-friends' do
      user = create(:user)
      friends = create_list(:user, 3)
      non_friend = create(:user)

      friends.each do |friend|
        create(:friendship, user:, friend:)
        create(:friendship, user: friend, friend: user)
      end

      create_list(:happy_thing, 4, user:)

      perform_enqueued_jobs do
        create(:happy_thing, user:)
      end

      delivered_emails = ActionMailer::Base.deliveries.map(&:to).flatten

      friends.each do |friend|
        expect(delivered_emails).to include(friend.email)
      end

      expect(delivered_emails).not_to include(non_friend.email)
    end

    after { clear_performed_jobs }
  end
end
