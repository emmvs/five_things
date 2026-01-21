# frozen_string_literal: true

# == Schema Information
#
# Table name: happy_thing_user_shares
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  friend_id      :bigint           not null
#  happy_thing_id :bigint           not null
#
# Indexes
#
#  index_happy_thing_user_shares_on_friend_id       (friend_id)
#  index_happy_thing_user_shares_on_happy_thing_id  (happy_thing_id)
#
# Foreign Keys
#
#  fk_rails_...  (friend_id => users.id)
#  fk_rails_...  (happy_thing_id => happy_things.id)
#
require 'rails_helper'

RSpec.describe HappyThingUserShare, type: :model do
  describe 'associations' do
    it { should belong_to(:happy_thing) }
    it { should belong_to(:friend).class_name('User') }
  end
end
