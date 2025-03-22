# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do # rubocop:disable Metrics/BlockLength
  before do
    @user = create(:user)
    @user.update_column(:encrypted_password, Devise::Encryptor.digest(User, '123456')) # Bypass validation
    sign_in @user
  end

  describe 'POST /login' do
    it 'allows users with weak passwords to log in' do
      post user_session_path, params: { user: { email: @user.email, password: '123456' } }
      follow_redirect!
      expect(response).to have_http_status(:success)
    end
  end

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

  describe 'PATCH /update' do
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
end
