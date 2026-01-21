# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboards', type: :request do
  before do
    @user = create(:user)
    sign_in @user, scope: :user
  end

  describe 'GET /' do
    context 'when install_prompt_shown is false' do
      it 'shows the install prompt modal' do
        @user.user_config.update(install_prompt_shown: false)
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Install 5 Things')
      end
    end

    context 'when install_prompt_shown is true' do
      it 'does not show the install prompt modal' do
        @user.user_config.update(install_prompt_shown: true)
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).not_to include('Install 5 Things')
      end
    end
  end
end
