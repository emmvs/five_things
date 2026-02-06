# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'HappyThings visibility', type: :request do
  let(:owner)     { create(:user, name: 'Owner') }
  let(:friend)    { create(:user, name: 'Friend') }
  let(:groupie)   { create(:user, name: 'Groupie') }
  let(:stranger)  { create(:user, name: 'Stranger') }

  # With bidirectional friendships, creating one friendship creates both records
  let!(:friendship_one) { create(:friendship, user: owner, friend:, accepted: true) }
  let!(:friendship_three) { create(:friendship, user: owner, friend: groupie, accepted: true) }

  let!(:happy_thing_user_shared)  { create(:happy_thing, user: owner, title: 'Directly Shared') }
  let!(:happy_thing_group_shared) { create(:happy_thing, user: owner, title: 'Group Shared') }
  let!(:happy_thing_private)      { create(:happy_thing, user: owner, title: 'Private One') }

  let!(:user_share)  { create(:happy_thing_user_share, happy_thing: happy_thing_user_shared, friend:) }

  let!(:group)       { create(:group, user: owner, name: 'Close Circle') }
  let!(:membership)  { create(:group_membership, group:, friend: groupie) }
  let!(:group_share) { create(:happy_thing_group_share, happy_thing: happy_thing_group_shared, group:) }

  describe 'visibility rules' do
    it 'shows directly shared happy thing to the friend' do
      sign_in friend, scope: :user
      get root_path
      expect(response.body).to include('Directly Shared')
    end

    it 'shows group shared happy thing to the group member' do
      sign_in groupie, scope: :user
      get root_path
      expect(response.body).to include('Group Shared')
    end

    it 'shows happy thing to the owner' do
      sign_in owner, scope: :user
      get root_path
      expect(response.body).to include('Directly Shared')
      expect(response.body).to include('Group Shared')
      expect(response.body).to include('Private One')
    end

    it 'does not show private happy thing to a stranger' do
      sign_in stranger, scope: :user
      get root_path
      expect(response.body).not_to include('Directly Shared')
      expect(response.body).not_to include('Group Shared')
      expect(response.body).not_to include('Private One')
    end
  end

  describe 'location sharing' do
    it 'saves location when share_location is checked' do
      sign_in owner, scope: :user

      expect do
        post happy_things_path, params: {
          happy_thing: {
            title: 'Shared with location',
            share_location: '1',
            place: 'Berlin',
            latitude: 52.5173885,
            longitude: 13.3951309
          }
        }
      end.to change(HappyThing, :count).by(1)

      happy_thing = HappyThing.last
      expect(happy_thing.share_location).to be(true)
      expect(happy_thing.place).to eq('Berlin')
      expect(happy_thing.latitude).to eq(52.5173885)
      expect(happy_thing.longitude).to eq(13.3951309)
    end
  end

  describe 'GET /calendar' do
    it 'returns a success response' do
      sign_in owner, scope: :user
      get calendar_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Tue')
    end
  end

  describe 'GET /friends/happy_things' do
    it 'returns a success response' do
      sign_in owner, scope: :user
      get friends_happy_things_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('What made you happy')
    end
  end

  describe 'GET /through_the_years' do
    it 'returns a success response' do
      sign_in owner, scope: :user
      get through_the_years_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Add a Happy Thing from a past year')
    end
  end

  describe 'GET /future_root' do
    it 'returns a success response' do
      sign_in owner, scope: :user
      get future_root_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('What made you happy today?')
    end
  end
end
