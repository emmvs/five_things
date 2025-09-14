# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  before do
    @user = create(:user)
    @user.update_column(:encrypted_password, Devise::Encryptor.digest(User, '123456')) # Bypass validation
    sign_in @user
  end

  describe 'CRUD operations' do
    describe 'GET /index' do
      it 'returns http success' do
        get '/users'
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /show' do
      it 'returns http success' do
        user = create(:user)
        user.update_column(:encrypted_password, Devise::Encryptor.digest(User, '123456'))
        get "/users/#{user.id}"
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'authentication' do # rubocop:disable Metrics/BlockLength
    describe 'POST /login' do
      it 'allows old users with weak passwords to log in' do
        post user_session_path, params: { user: { email: @user.email, password: '123456' } }
        follow_redirect!
        expect(response).to have_http_status(:success)
      end
    end

  describe 'User sign up and email confirmation flow' do
    it 'allows a user to sign up, confirm their email, and log in' do
      sign_out @user
      ActionMailer::Base.deliveries.clear

        post user_registration_path, params: {
          user: {
            first_name: 'Testy',
            last_name: 'Tester',
            email: 'testy-confirm@example.com',
            password: 'StrongPass1!',
            password_confirmation: 'StrongPass1!'
          }
        }

        expect(response).to have_http_status(:found)
        expect(ActionMailer::Base.deliveries.size).to eq(1)
        mail = ActionMailer::Base.deliveries.last
        confirmation_url = mail.body.encoded.match(/href="(?<url>.+?)">/)[:url]

        get confirmation_url
        follow_redirect!
        expect(response.body).to include('Your email address has been successfully confirmed')

        post user_session_path, params: {
          user: {
            email: 'testy-confirm@example.com',
            password: 'StrongPass1!'
          }
        }
        expect(response).to have_http_status(:found)
        follow_redirect!
        expect(response.body).to include('Current Happy Streak')
      end
    end

    describe 'PATCH /update registration' do
      it 'allows existing users to keep their weak password' do
        patch user_registration_path, params: { user: { first_name: 'Updated Name' } }
        expect(response).to have_http_status(:success)
      end

      it 'enforces strong password rules only when updating the password' do
        patch user_registration_path, params: {
          user: { password: 'weak', password_confirmation: 'weak', current_password: '123456' }
        }
        expect(response.body).to include(I18n.t('errors.models.user.password.invalid'))
      end
    end

    describe 'DELETE /destroy' do
      it 'allows users to delete their account' do
        delete user_registration_path
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
        expect(User.find_by(id: @user.id)).to be_nil
      end
    end
  end

  describe 'GET /friends' do
    it 'returns http success' do
      get friends_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('My Friends')
    end
  end
end
