# frozen_string_literal: true

# == Schema Information
#
# Table name: happy_things
#
#  id             :bigint           not null, primary key
#  body           :text
#  latitude       :float
#  longitude      :float
#  place          :string
#  share_location :boolean
#  start_time     :datetime
#  status         :integer
#  title          :string           not null
#  visibility     :string           default("public")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  category_id    :bigint
#  user_id        :bigint           not null
#
# Indexes
#
#  index_happy_things_on_category_id  (category_id)
#  index_happy_things_on_user_id      (user_id)
#  index_happy_things_on_visibility   (visibility)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe HappyThing, type: :model do
  include ActiveJob::TestHelper

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

  describe 'Callbacks' do
    context 'when a user adds 5 happy things in a day' do
      it 'sends an email to each of their friends' do
        user = create(:user)
        friends = create_list(:user, 3)

        # With bidirectional friendships, creating one friendship creates both records
        friends.each do |friend|
          create(:friendship, user:, friend:, accepted: true)
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

      # With bidirectional friendships, creating one friendship creates both records
      friends.each do |friend|
        create(:friendship, user:, friend:, accepted: true)
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
