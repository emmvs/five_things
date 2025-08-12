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
    it 'sets the start_time if not already present' do
      happy_thing = build(:happy_thing, start_time: nil)
      happy_thing.add_date_time_to_happy_thing
      expect(happy_thing.start_time).to be_present
    end

    it 'does not change start_time if already present' do
      time = DateTime.now
      happy_thing = build(:happy_thing, start_time: time)
      expect { happy_thing.add_date_time_to_happy_thing }.not_to change(happy_thing, :start_time)
    end
  end

  describe 'Callbacks' do # rubocop:disable Metrics/BlockLength
    let(:user) { create(:user) }
    before { ActionMailer::Base.deliveries.clear }

    def create_bi_directional_friendship(user, friend)
      create(:friendship, user:, friend:)
      create(:friendship, user: friend, friend: user)
    end

    context 'when a user adds 5 happy things in a day' do # rubocop:disable Metrics/BlockLength
      it 'sends an email to each of their friends that opted-in to receiving emails' do
        friends = create_list(:user, 3, email_opt_in: true)

        friends.each do |friend|
          create_bi_directional_friendship(user, friend)
        end

        perform_enqueued_jobs do
          create_list(:happy_thing, 5, user:)
        end

        delivered_emails = ActionMailer::Base.deliveries.map(&:to).flatten

        friends.each do |friend|
          expect(delivered_emails).to include(friend.email)
        end
      end

      it 'sends no email to their friends that opted-out of receiving emails' do
        opted_in_friend = create(:user, email_opt_in: true)
        create_bi_directional_friendship(user, opted_in_friend)

        opted_out_friend = create(:user, email_opt_in: false)
        create_bi_directional_friendship(user, opted_out_friend)

        perform_enqueued_jobs do
          create_list(:happy_thing, 5, user:)
        end

        delivered_emails = ActionMailer::Base.deliveries.map(&:to).flatten

        expect(delivered_emails).to include(opted_in_friend.email)
        expect(delivered_emails).not_to include(opted_out_friend.email)
      end

      it 'sends an email to their friends but not to non-friends' do
        friend = create(:user, email_opt_in: true)
        non_friend = create(:user, email_opt_in: true)
        create_bi_directional_friendship(user, friend)

        perform_enqueued_jobs do
          create_list(:happy_thing, 5, user:)
        end

        delivered_emails = ActionMailer::Base.deliveries.map(&:to).flatten

        expect(delivered_emails).to include(friend.email)
        expect(delivered_emails).not_to include(non_friend.email)
      end

      it 'sends no email if user has no friends' do
        create_list(:happy_thing, 5, user:)

        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it 'only sends one email if happy thing #5 is deleted and recreated' do
        friend = create(:user, email_opt_in: true)
        create_bi_directional_friendship(user, friend)

        perform_enqueued_jobs do
          create_list(:happy_thing, 5, user:)
        end

        user.happy_things.last.destroy

        perform_enqueued_jobs do
          create(:happy_thing, user:)
        end

        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end

      it 'allows daily email to be sent every day' do # rubocop:disable Metrics/BlockLength
        friend = create(:user, email_opt_in: true)
        create_bi_directional_friendship(user, friend)

        today = Time.current
        tomorrow = today + 1.day
        yesterday = today - 1.day

        travel_to today do
          expect do
            perform_enqueued_jobs do
              create_list(:happy_thing, 5, user:)
            end
          end.to change(ActionMailer::Base.deliveries, :count).by(1)
        end

        travel_to tomorrow do
          expect do
            perform_enqueued_jobs do
              create_list(:happy_thing, 5, user:)
            end
          end.to change(ActionMailer::Base.deliveries, :count).by(1)
        end

        travel_to yesterday do
          expect do
            perform_enqueued_jobs do
              create_list(:happy_thing, 5, user:)
            end
          end.to change(ActionMailer::Base.deliveries, :count).by(1)
        end
      end
    end
  end
end
