# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do # rubocop:disable Metrics/BlockLength
  describe 'Validations' do # rubocop:disable Metrics/BlockLength
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is not valid with links in the name' do
      user = build(:user, first_name: 'http://Emma')
      expect(user).not_to be_valid
    end

    it 'is not valid with www. in the name' do
      user = build(:user, first_name: 'www.pornhub.org')
      expect(user).not_to be_valid
    end

    it 'is not valid with https in the name' do
      user = build(:user, first_name: 'https://Emma')
      expect(user).not_to be_valid
    end

    it 'enforces strong password rules only when updating the password' do
      user = create(:user)  # Persisted record
      user.password = 'weak'
      user.password_confirmation = 'weak'
      expect(user).not_to be_valid
    end
  end

  describe '#happy_streak' do
    let(:user) { create(:user) }

    context 'when there are no happy things' do
      it 'returns a streak of 0' do
        expect(user.happy_streak).to eq(0)
      end
    end

    context 'when there are consecutive happy things' do
      before do
        3.times { |n| create(:happy_thing, user:, start_time: 2.days.ago + n.days) }
      end

      it 'returns the correct streak count' do
        expect(user.happy_streak).to eq(3)
      end
    end

    context 'when happy things are not consecutive' do
      before do
        create(:happy_thing, user:, start_time: 3.days.ago)
        create(:happy_thing, user:, start_time: 1.day.ago)
      end

      it 'returns a streak ending at the first gap' do
        expect(user.happy_streak).to eq(1)
      end
    end
  end

  describe '.from_omniauth' do
    let(:auth_hash) do
      OmniAuth::AuthHash.new({
        provider: 'google_oauth2',
        uid: '123456789',
        info: {
          name: 'Emma Who',
          email: 'emmazing@gmail.com'
        }
      })
    end

    context 'when brand new user signs in with OAuth' do
      it 'creates new auto-confirmed user with parsed name' do
        expect {
          User.from_omniauth(auth_hash)
        }.to change(User, :count).by(1)
        
        user = User.last
        expect(user.first_name).to eq('Emma')
        expect(user.confirmed?).to be true
        expect(user.provider).to eq('google_oauth2')
      end
    end

    context 'when repeat OAuth login' do
      it 'finds existing user by provider and uid' do
        existing_user = create(:user, 
          provider: auth_hash.provider, 
          uid: auth_hash.uid, 
          email: auth_hash.info.email
        )
        
        user = User.from_omniauth(auth_hash)
        
        expect(user).to eq(existing_user)
        expect(User.count).to eq(1)
      end
    end

    context 'when confirmed manual user tries OAuth' do
      it 'links OAuth to existing confirmed account' do
        existing_user = create(:user, email: auth_hash.info.email, confirmed_at: 1.day.ago)
        
        user = User.from_omniauth(auth_hash)
        
        expect(user).to eq(existing_user)
        expect(user.provider).to eq('google_oauth2')
        expect(user.uid).to eq('123456789')
        expect(User.count).to eq(1)
      end
    end

    context 'when unconfirmed manual user tries OAuth' do
      it 'links OAuth and auto-confirms existing account' do
        existing_user = create(:user, email: auth_hash.info.email, confirmed_at: nil)
        
        user = User.from_omniauth(auth_hash)
        
        expect(user).to eq(existing_user)
        expect(user.provider).to eq('google_oauth2')
        expect(user.confirmed?).to be true
        expect(User.count).to eq(1)
      end
    end

    context 'when OAuth user has different email' do
      it 'creates separate user for different email' do
        create(:user, email: 'wonky@example.com')
        
        expect {
          User.from_omniauth(auth_hash)
        }.to change(User, :count).by(1)
        
        expect(User.count).to eq(2)
        oauth_user = User.find_by(email: 'emmazing@gmail.com')
        expect(oauth_user.provider).to eq('google_oauth2')
      end
    end


  end
end
