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
      user = create(:user) # Persisted record
      user.password = 'weak'
      user.password_confirmation = 'weak'
      expect(user).not_to be_valid
    end

    it 'accepts a strong password' do
      strong_password = "Aa1!#{SecureRandom.hex(6)}" # pragma: allowlist secret
      user = build(:user, password: strong_password, password_confirmation: strong_password)
      expect(user).to be_valid
    end

    it 'rejects missing uppercase' do
      no_uppercase = "aa1!#{SecureRandom.hex(6)}" # pragma: allowlist secret
      user = build(:user, password: no_uppercase, password_confirmation: no_uppercase)
      expect(user).to be_invalid
      expect(user.errors[:password]).to be_present
    end

    it 'rejects missing special char' do
      no_special = "Aa1#{SecureRandom.hex(6)}" # pragma: allowlist secret
      user = build(:user, password: no_special, password_confirmation: no_special)
      expect(user).to be_invalid
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

  describe '.from_omniauth' do # rubocop:disable Metrics/BlockLength
    let(:auth_hash) { build(:oauth_auth_hash) }

    context 'when brand new user signs in with OAuth' do
      it 'creates new auto-confirmed user with parsed name and sends no confirmation email' do
        ActionMailer::Base.deliveries.clear

        expect do
          User.from_omniauth(auth_hash)
        end.to change(User, :count).by(1)

        user = User.last
        expect(user.first_name).to eq('Emma')
        expect(user.confirmed?).to be true
        expect(user.provider).to eq('google_oauth2')
        expect(ActionMailer::Base.deliveries.size).to eq(0)
      end
    end

    context 'when repeat OAuth login' do
      it 'finds existing user by provider and uid' do
        existing_user = create(:user,
                               provider: auth_hash.provider,
                               uid: auth_hash.uid,
                               email: auth_hash.info.email)

        user = User.from_omniauth(auth_hash)

        expect(user).to eq(existing_user)
        expect(User.count).to eq(1)
      end
    end

    context 'when confirmed manual user tries OAuth' do
      it 'links OAuth to existing confirmed account' do
        existing_user = create(:user,
                               email: auth_hash.info.email,
                               confirmed_at: 1.day.ago)

        user = User.from_omniauth(auth_hash)
        existing_user.reload

        expect(user).to eq(existing_user)
        expect(existing_user.provider).to eq('google_oauth2')
        expect(existing_user.uid).to eq('123456789')
        expect(User.count).to eq(1)
      end
    end

    context 'when unconfirmed manual user tries OAuth' do
      it 'links OAuth and auto-confirms existing account' do
        existing_user = create(:user,
                               email: auth_hash.info.email,
                               confirmed_at: nil)

        user = User.from_omniauth(auth_hash)
        existing_user.reload

        expect(user).to eq(existing_user)
        expect(existing_user.provider).to eq('google_oauth2')
        expect(existing_user.uid).to eq('123456789')
        expect(existing_user.confirmed?).to be true
        expect(User.count).to eq(1)
      end
    end

    context 'when OAuth user has different email' do
      it 'creates separate user for different email' do
        create(:user,
               email: 'different@email.com')

        expect do
          User.from_omniauth(auth_hash)
        end.to change(User, :count).by(1)

        expect(User.count).to eq(2)
        oauth_user = User.find_by(email: 'emmazing@gmail.com')
        expect(oauth_user.provider).to eq('google_oauth2')
      end
    end

    context 'when Google provides problematic name data' do
      let(:bad_name_auth) { auth_hash.deep_merge(info: { name: 'E.' }) }

      it 'creates user with valid extracted name' do
        expect do
          User.from_omniauth(bad_name_auth)
        end.to change(User, :count).by(1)

        user = User.last
        expect(user.first_name).to be_present
        expect(user.first_name).not_to eq('E.')
        expect(user.first_name).to eq('Emmazing')
      end
    end
  end

  describe '.extract_first_name' do
    it 'returns first word if valid' do
      expect(User.extract_first_name('Emma Who', 'emmazing@gmail.com')).to eq('Emma')
    end

    it 'returns full name if first word is too short' do
      expect(User.extract_first_name('I love rspec 🥳', 'email@gmail.com')).to eq('I love rspec 🥳')
      expect(User.extract_first_name('A. B. B. A.', 'email@gmail.com')).to eq('A. B. B. A.')
    end

    it 'returns first word of email if name isn\'t usable' do
      expect(User.extract_first_name('www.<script>.com', 'bob.virtuous@gmail.com')).to eq('Bob')
      expect(User.extract_first_name('', 'bob.virtuous@gmail.com')).to eq('Bob')
      expect(User.extract_first_name(('Wayyyyyyyytoolong' * 99).to_s, 'bob.long@gmail.com')).to eq('Bob')
    end

    it 'returns "User" if name and email aren\'t usable' do
      expect(User.extract_first_name(nil, nil)).to eq('User')
    end
  end
end
