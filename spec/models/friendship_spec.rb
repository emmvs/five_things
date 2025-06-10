# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Friendship, type: :model do # rubocop:disable Metrics/BlockLength
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:friend).class_name('User') }
  end

  describe 'validations' do
    it 'is invalid without a value for accepted' do
      expect(build(:friendship, accepted: nil)).not_to be_valid
    end

    it 'defaults to false' do
      friendship = described_class.new
      expect(friendship.accepted).to eq(false)
    end
  end

  describe 'scopes' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    let!(:accepted_friendship) { create(:friendship, user: user1, friend: user2, accepted: true) }
    let!(:pending_friendship)  { create(:friendship, user: user2, friend: user1, accepted: false) }

    it 'returns accepted friendships' do
      expect(Friendship.accepted).to include(accepted_friendship)
      expect(Friendship.accepted).not_to include(pending_friendship)
    end

    it 'returns pending friendships' do
      expect(Friendship.pending).to include(pending_friendship)
      expect(Friendship.pending).not_to include(accepted_friendship)
    end
  end
end
