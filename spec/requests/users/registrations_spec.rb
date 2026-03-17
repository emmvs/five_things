# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::Registrations', type: :request do
  before do
    @user = create(:user)
    sign_in @user
  end

  describe 'PATCH /settings' do
    it 'updates profile information without requiring password' do
      patch settings_path, params: { user: { name: 'My name is better than yours' } }
      @user.reload

      expect(@user.name).to eq('My name is better than yours')
    end

    it 'updates password when current password is provided' do
      patch settings_path, params: { user:
      { password: 'Giggle?!3FluffSomething', password_confirmation: 'Giggle?!3FluffSomething',
        current_password: @user.password } }
      @user.reload

      expect(@user.valid_password?('Giggle?!3FluffSomething')).to be_truthy
    end

    it 'does not update password when current password is not provided' do
      patch settings_path, params: { user:
      { password: 'Giggle?!3FluffSomething', password_confirmation: 'Giggle?!3FluffSomething',
        current_password: '' } }
      @user.reload

      expect(@user.valid_password?(@user.password)).to be_truthy
      expect(@user.valid_password?('Giggle?!3FluffSomething')).to be_falsey
    end
  end
end
