# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'HappyThings visibility', type: :request do # rubocop:disable Metrics/BlockLength
  let(:owner)     { create(:user, first_name: 'Owner') }
  let(:friend)    { create(:user, first_name: 'Friend') }
  let(:groupie)   { create(:user, first_name: 'Groupie') }
  let(:stranger)  { create(:user, first_name: 'Stranger') }

  let!(:friendship_one) { create(:friendship, user: owner, friend:, accepted: true) }
  let!(:friendship_two) { create(:friendship, user: friend, friend: owner, accepted: true) }

  let!(:friendship_three) { create(:friendship, user: owner, friend: groupie, accepted: true) }
  let!(:friendship_four) { create(:friendship, user: groupie, friend: owner, accepted: true) }

  let!(:happy_thing_user_shared)  { create(:happy_thing, user: owner, title: 'Directly Shared') }
  let!(:happy_thing_group_shared) { create(:happy_thing, user: owner, title: 'Group Shared') }
  let!(:happy_thing_private)      { create(:happy_thing, user: owner, title: 'Private One') }

  let!(:user_share)  { create(:happy_thing_user_share, happy_thing: happy_thing_user_shared, friend:) }

  let!(:group)       { create(:group, user: owner, name: 'Close Circle') }
  let!(:membership)  { create(:group_membership, group:, friend: groupie) }
  let!(:group_share) { create(:happy_thing_group_share, happy_thing: happy_thing_group_shared, group:) }

  describe 'visibility rules' do
    it 'shows directly shared happy thing to the friend' do
      sign_in friend
      get root_path
      expect(response.body).to include('Directly Shared')
    end

    it 'shows group shared happy thing to the group member' do
      sign_in groupie
      get root_path
      expect(response.body).to include('Group Shared')
    end

    it 'shows happy thing to the owner' do
      sign_in owner
      get root_path
      expect(response.body).to include('Directly Shared')
      expect(response.body).to include('Group Shared')
      expect(response.body).to include('Private One')
    end

    it 'does not show private happy thing to a stranger' do
      sign_in stranger
      get root_path
      expect(response.body).not_to include('Directly Shared')
      expect(response.body).not_to include('Group Shared')
      expect(response.body).not_to include('Private One')
    end
  end

  describe 'location sharing' do
    it 'saves location when share_location is checked' do
      sign_in owner

      expect do
        post happy_things_path, params: {
          happy_thing: {
            title: 'Shared with location',
            share_location: '1',
            place: 'Berlin'
          }
        }
      end.to change(HappyThing, :count).by(1)

      happy_thing = HappyThing.last
      expect(happy_thing.share_location).to be(true)
      expect(happy_thing.latitude).to be_within(0.001).of(52.5173885)
      expect(happy_thing.longitude).to be_within(0.001).of(13.3951309)
      expect(happy_thing.place).to eq('Berlin')
    end
  end
end
