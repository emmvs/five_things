# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Comments authorization', type: :request do
  let(:owner)    { create(:user, name: 'Owner') }
  let(:friend)   { create(:user, name: 'Friend') }
  let(:stranger) { create(:user, name: 'Stranger') }

  let!(:friendship) { create(:friendship, user: owner, friend:, accepted: true) }
  let!(:happy_thing) { create(:happy_thing, user: owner, title: 'Private One') }

  describe 'POST /happy_things/:happy_thing_id/comments' do
    it 'allows a friend to comment' do
      sign_in friend, scope: :user

      expect do
        post happy_thing_comments_path(happy_thing), params: { comment: { content: 'Nice!' } }
      end.to change(Comment, :count).by(1)
    end

    it 'does not allow a stranger to comment on a happy thing they cannot see' do
      sign_in stranger, scope: :user

      expect do
        post happy_thing_comments_path(happy_thing), params: { comment: { content: 'Sneaky' } }
      end.to raise_error(ActiveRecord::RecordNotFound)

      expect(Comment.count).to eq(0)
    end
  end
end
