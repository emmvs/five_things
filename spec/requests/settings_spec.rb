# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings', type: :request do # rubocop:disable Metrics/BlockLength
  let(:user) { create(:user) }

  before do
    sign_in user
  end
  describe 'GET /settings' do
    it 'returns a success response' do
      get settings_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Edit User')
    end
  end

  describe 'PATCH /settings' do
    context 'with valid params' do
      it 'changes the users attributes' do
        patch settings_path, params: { user: { first_name: 'Friendly Ghost', emoji: '👻' } }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(settings_path)
        expect(user.reload.first_name).to eq('Friendly Ghost')
        expect(user.reload.emoji).to eq('👻')
      end
    end

    context 'with invalid params' do
      it 'returns rerenders the edit page' do
        patch settings_path, params: { user: { emoji: '👻', password: user.password,
                                               password_confirmation: user.password,
                                               current_password: 'wrong password' } }

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Edit User')
        expect(response.body).to include('Current password is invalid')
      end
    end
  end
end
