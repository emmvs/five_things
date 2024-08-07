# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HappyThing, type: :model do
  describe 'Validations' do
    it 'has a title' do
      should validate_presence_of(:title)
    end
  end

  describe 'Associations' do
    it 'belongs to a user' do
      should belong_to(:user)
    end
  end

  describe 'Scope' do
    it 'orders by created_at in descending order' do
      user = create(:user)
      happy_thing1 = create(:happy_thing, user:, created_at: 2.days.ago)
      happy_thing2 = create(:happy_thing, user:, created_at: 1.day.ago)
      expect(described_class.all).to eq([happy_thing2, happy_thing1])
    end
  end

  describe 'Methods' do
    it 'sets the start_time if not already present' do
      happy_thing = build(:happy_thing, start_time: nil)
      happy_thing.add_date_time_to_happy_thing
      expect(happy_thing.start_time).to be_present
    end

    it 'does not set the start_time if already present' do
      happy_thing = build(:happy_thing, start_time: DateTime.now)
      expect { happy_thing.add_date_time_to_happy_thing }.to_not change(happy_thing, :start_time)
    end
  end

  describe 'callbacks' do
    context 'when a user adds 5 happy things in a day' do
      it 'sends an email to their friends' do
        user = create(:user)
        3.times do
          friend = create(:user)
          create(:friendship, user:, friend:)
          create(:friendship, user: friend, friend: user)
        end

        # Debugging
        puts "Friends count: #{user.friends.count}"
        puts "Inverse Friends count: #{user.inverse_friends.count}"

        expect do
          5.times { create(:happy_thing, user:) }
        end.to change { ActionMailer::Base.deliveries.count }.by(3)
      end
    end
  end
end
