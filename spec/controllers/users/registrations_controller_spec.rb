require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do # rubocop:disable Metrics/BlockLength
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in user
  end

  describe 'PATCH #update' do
    it 'updates profile information without requiring password' do
      patch :update, params: { user: { first_name: 'My name is better than yours' } }
      user.reload

      expect(user.first_name).to eq('My name is better than yours')
    end

    it 'updates password when current password is provided' do
      patch :update, params: { user:
      { password: 'Giggle?!3FluffSomething', password_confirmation: 'Giggle?!3FluffSomething',
        current_password: user.password } }
      user.reload

      expect(user.valid_password?('Giggle?!3FluffSomething')).to be_truthy
    end
  end

  it 'does not update password when current password is not provided' do
    patch :update, params: { user:
    { password: 'Giggle?!3FluffSomething', password_confirmation: 'Giggle?!3FluffSomething',
      current_password: '' } }
    user.reload

    expect(user.valid_password?(user.password)).to be_truthy
    expect(user.valid_password?('Giggle?!3FluffSomething')).to be_falsey
  end
end
