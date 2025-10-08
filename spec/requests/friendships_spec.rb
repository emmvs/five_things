# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Friendships', type: :request do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }

  before do
    sign_in user
  end

  describe 'POST /create' do
    it 'creates a new friendship' do
      expect do
        post friendships_path, params: { friend_id: friend.id }
      end.to change(Friendship, :count).by(1)
      expect(response).to have_http_status(:redirect) # or :success
    end
  end

  describe 'PUT /update' do
    let(:friendship) { create(:friendship, user:, friend:) }

    it 'updates the friendship' do
      put friendship_path(friendship), params: { friendship: { accepted: true } }
      expect(response).to have_http_status(:redirect)
      expect(friendship.reload.accepted).to eq(true)
    end
  end

  describe 'DELETE /destroy' do
    let!(:friendship) { create(:friendship, user:, friend:) }

    it 'deletes the friendship' do
      expect do
        delete friendship_path(friendship)
      end.to change(Friendship, :count).by(-1)
      expect(response).to have_http_status(:redirect)
    end
  end
end
