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

    it 'does not show user-shared happy thing to a friend who is not the share target' do
      sign_in groupie, scope: :user
      get root_path
      expect(response.body).not_to include('Directly Shared')
    end

    it 'does not show group-shared happy thing to a friend outside that group' do
      sign_in friend, scope: :user
      get root_path
      expect(response.body).not_to include('Group Shared')
    end

    it 'does not show private happy thing to a stranger' do
      sign_in stranger, scope: :user
      get root_path
      expect(response.body).not_to include('Directly Shared')
      expect(response.body).not_to include('Group Shared')
      expect(response.body).not_to include('Private One')
    end
  end

  describe 'creating with visibility' do
    it 'creates a happy thing visible to everyone when no shared_with_ids are provided' do
      sign_in owner, scope: :user

      expect do
        post happy_things_path, params: { happy_thing: { title: 'For everyone' } }
      end.to change(HappyThing, :count).by(1)

      happy_thing = HappyThing.last
      expect(happy_thing.happy_thing_user_shares).to be_empty
      expect(happy_thing.happy_thing_group_shares).to be_empty
    end

    it 'creates a happy thing visible only to the owner with only_me' do
      sign_in owner, scope: :user

      expect do
        post happy_things_path, params: {
          happy_thing: { title: 'My secret', shared_with_ids: ['only_me'] }
        }
      end.to change(HappyThing, :count).by(1)

      happy_thing = HappyThing.last
      expect(happy_thing.shared_users).to contain_exactly(owner)

      sign_in friend, scope: :user
      get root_path
      expect(response.body).not_to include('My secret')

      sign_in owner, scope: :user
      get root_path
      expect(response.body).to include('My secret')
    end

    it 'creates a happy thing shared with a specific friend' do
      sign_in owner, scope: :user

      expect do
        post happy_things_path, params: {
          happy_thing: { title: 'Just for you', shared_with_ids: ["friend_#{friend.id}"] }
        }
      end.to change(HappyThing, :count).by(1)

      happy_thing = HappyThing.last
      expect(happy_thing.shared_users).to contain_exactly(friend)
    end

    it 'creates a happy thing shared with a group' do
      sign_in owner, scope: :user

      expect do
        post happy_things_path, params: {
          happy_thing: { title: 'For the group', shared_with_ids: ["group_#{group.id}"] }
        }
      end.to change(HappyThing, :count).by(1)

      happy_thing = HappyThing.last
      expect(happy_thing.shared_groups).to contain_exactly(group)
    end

    it 'creates a happy thing shared with both a friend and a group' do
      sign_in owner, scope: :user

      post happy_things_path, params: {
        happy_thing: {
          title: 'Mixed sharing',
          shared_with_ids: ["friend_#{friend.id}", "group_#{group.id}"]
        }
      }

      happy_thing = HappyThing.last
      expect(happy_thing.shared_users).to contain_exactly(friend)
      expect(happy_thing.shared_groups).to contain_exactly(group)
    end

    it 'replaces visibility shares on update' do
      sign_in owner, scope: :user

      patch happy_thing_path(happy_thing_user_shared), params: {
        happy_thing: {
          title: 'Now for the group',
          shared_with_ids: ["group_#{group.id}"]
        }
      }

      happy_thing_user_shared.reload
      expect(happy_thing_user_shared.shared_users).to be_empty
      expect(happy_thing_user_shared.shared_groups).to contain_exactly(group)
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
      expect(response.body).to include(I18n.t('dashboard.what_made_you_happy'))
    end
  end

  describe 'GET /through_the_years' do
    it 'returns a success response' do
      sign_in owner, scope: :user
      get through_the_years_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('through_the_years.add_from_past'))
    end
  end

  describe 'GET /future_root' do
    it 'returns a success response' do
      sign_in owner, scope: :user
      get future_root_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('dashboard.what_made_you_happy_today'))
    end
  end

  describe 'GET /happy_things/:date (show_by_date)' do
    let(:yesterday) { Date.yesterday }

    it 'shows the add form when only the current user has few happy things' do
      sign_in owner, scope: :user

      create_list(:happy_thing, 3, user: owner, start_time: yesterday.noon)
      create_list(:happy_thing, 5, user: friend, start_time: yesterday.noon)

      get happy_things_by_date_path(date: yesterday)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('happy_things.forgot_add_more'))
    end

    it 'shows the add form even when friends collectively have 10+ happy things' do
      sign_in owner, scope: :user

      create_list(:happy_thing, 2, user: owner, start_time: yesterday.noon)
      create_list(:happy_thing, 5, user: friend, start_time: yesterday.noon)
      create_list(:happy_thing, 5, user: groupie, start_time: yesterday.noon)

      get happy_things_by_date_path(date: yesterday)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('happy_things.forgot_add_more'))
    end

    it 'hides the add form when the current user already has 5 happy things for that date' do
      sign_in owner, scope: :user

      create_list(:happy_thing, 5, user: owner, start_time: yesterday.noon)

      get happy_things_by_date_path(date: yesterday)

      expect(response).to have_http_status(:success)
      expect(response.body).not_to include(I18n.t('happy_things.forgot_add_more'))
    end
  end
end
