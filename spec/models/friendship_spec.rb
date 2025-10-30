# frozen_string_literal: true

# == Schema Information
#
# Table name: friendships
#
#  id         :bigint           not null, primary key
#  accepted   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  friend_id  :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_friendships_on_friend_id              (friend_id)
#  index_friendships_on_user_id                (user_id)
#  index_friendships_on_user_id_and_friend_id  (user_id,friend_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (friend_id => users.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Friendship, type: :model do
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
    let!(:user3) { create(:user) }

    # With bidirectional friendships, creating one friendship creates TWO records
    let!(:accepted_friendship) { create(:friendship, user: user1, friend: user2, accepted: true) }
    let!(:pending_friendship)  { create(:friendship, user: user1, friend: user3, accepted: false) }

    it 'returns accepted friendships' do
      accepted_friendships = Friendship.accepted
      # Should include both the original AND the inverse
      expect(accepted_friendships.pluck(:user_id, :friend_id)).to include(
        [user1.id, user2.id],
        [user2.id, user1.id]
      )
    end

    it 'returns pending friendships' do
      pending_friendships = Friendship.pending
      # Should include both the original AND the inverse
      expect(pending_friendships.pluck(:user_id, :friend_id)).to include(
        [user1.id, user3.id],
        [user3.id, user1.id]
      )
    end
  end
end
