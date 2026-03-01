# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /settings' do
    it 'returns a success response' do
      get settings_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('settings.title'))
    end

    it 'renders the page in the users preferred locale' do
      user.update!(locale: 'de')
      get settings_path

      expect(response.body).to include(I18n.t('settings.title', locale: :de))
    end
  end

  describe 'PATCH /settings' do
    context 'with valid params' do
      it 'changes the users attributes' do
        patch settings_path, params: { user: { name: 'Friendly Ghost', emoji: '👻' } }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(settings_path)
        expect(user.reload.name).to eq('Friendly Ghost')
        expect(user.reload.emoji).to eq('👻')
      end

      it 'updates the locale preference' do
        patch settings_path, params: { user: { locale: 'de' } }

        expect(response).to redirect_to(settings_path)
        expect(user.reload.locale).to eq('de')
      end
    end

    context 'with invalid params' do
      it 'rerenders the edit page' do
        patch settings_path, params: { user: { emoji: '👻', password: user.password,
                                               password_confirmation: user.password,
                                               current_password: 'wrong password' } }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.t('settings.title'))
      end
    end
  end
end
