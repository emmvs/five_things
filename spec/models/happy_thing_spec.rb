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
    def create_friendships(user, friends)
      friends.each do |friend|
        create(:friendship, user:, friend:, accepted: true)
      end
    end

    def delivered_recipients
      ActionMailer::Base.deliveries.map(&:to).flatten
    end

    context 'when a user adds 5 happy things in a day' do
      it 'sends exactly one email to each opted-in friend' do
        user = create(:user)
        friends = create_list(:user, 3, email_opt_in: true)
        create_friendships(user, friends)

        perform_enqueued_jobs do
          create_list(:happy_thing, 5, user:)
        end

        delivered_emails = delivered_recipients

        expect(delivered_emails.size).to eq(3)
        friends.each do |friend|
          expect(delivered_emails.count(friend.email)).to eq(1)
        end
        expect(user.reload.friends_notified_today?).to be(true)
      end

      it 'does not notify friends again after deleting and re-adding a happy thing the same day' do
        user = create(:user)
        friends = create_list(:user, 2, email_opt_in: true)
        create_friendships(user, friends)

        perform_enqueued_jobs do
          create_list(:happy_thing, 5, user:)
        end

        expect(delivered_recipients.size).to eq(2)

        user.happy_things.last.destroy

        perform_enqueued_jobs do
          create(:happy_thing, user:)
        end

        expect(delivered_recipients.size).to eq(2)
        friends.each do |friend|
          expect(delivered_recipients.count(friend.email)).to eq(1)
        end
      end
    end
  end

  describe 'Mailers' do
    before { clear_enqueued_jobs }

    def create_friendships(user, friends)
      friends.each do |friend|
        create(:friendship, user:, friend:, accepted: true)
      end
    end

    def delivered_recipients
      ActionMailer::Base.deliveries.map(&:to).flatten
    end

    it 'sends an email to each opted-in friend but not to non-friends' do
      user = create(:user)
      friends = create_list(:user, 3, email_opt_in: true)
      non_friend = create(:user, email_opt_in: true)
      create_friendships(user, friends)

      create_list(:happy_thing, 4, user:)

      perform_enqueued_jobs do
        create(:happy_thing, user:)
      end

      delivered_emails = delivered_recipients

      expect(delivered_emails.size).to eq(3)
      friends.each do |friend|
        expect(delivered_emails.count(friend.email)).to eq(1)
      end

      expect(delivered_emails).not_to include(non_friend.email)
    end

    it 'does not send emails to friends who have not opted in' do
      user = create(:user)
      opted_in_friend = create(:user, email_opt_in: true)
      opted_out_friend = create(:user, email_opt_in: false)
      create_friendships(user, [opted_in_friend, opted_out_friend])

      perform_enqueued_jobs do
        create_list(:happy_thing, 5, user:)
      end

      delivered_emails = delivered_recipients

      expect(delivered_emails.size).to eq(1)
      expect(delivered_emails).to eq([opted_in_friend.email])
      expect(delivered_emails).not_to include(opted_out_friend.email)
    end

    after { clear_performed_jobs }
  end
end
