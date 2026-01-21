# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserConfigs', type: :request do
  before do
    @user = create(:user)
    sign_in @user, scope: :user
  end

  describe 'PATCH /update' do
    it 'updates the user config' do
      expect(@user.user_config.install_prompt_shown).to be(false)
      patch user_config_path, params: { user_config: { install_prompt_shown: true } }
      expect(response).to have_http_status(:ok)
      expect(@user.reload.user_config.install_prompt_shown).to be(true)
    end

    it "creates user_config for users that don't have one" do
      @user.user_config.destroy
      @user.reload
      expect(@user.user_config).to be_nil

      patch user_config_path, params: { user_config: { install_prompt_shown: true } }
      expect(response).to have_http_status(:ok)
      expect(@user.user_config.install_prompt_shown).to be(true)
    end
  end
end
