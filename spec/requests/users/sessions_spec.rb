# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::Sessions', type: :request do
  let(:user) { create(:user) }

  describe 'POST /users/sign_in' do
    context 'with standard password-based login' do
      it 'signs in with valid credentials' do
        post user_session_path, params: { user: { email: user.email, password: user.password } }

        expect(response).to redirect_to(authenticated_root_path)
        follow_redirect!
        expect(controller.current_user).to eq(user)
      end

      it 'does not sign in with invalid credentials' do
        post user_session_path, params: { user: { email: user.email, password: 'wrong' } }

        expect(controller.current_user).to be_nil
      end
    end

    context 'with passwordless login enabled' do
      before do
        allow_any_instance_of(Users::SessionsController).to receive(:allow_passwordless?).and_return(true)
      end

      it 'signs in with just an email (no password)' do
        post user_session_path, params: { user: { email: user.email, password: '' } }

        expect(response).to redirect_to(authenticated_root_path)
        follow_redirect!
        expect(controller.current_user).to eq(user)
      end

      it 'shows an error for an unknown email' do
        post user_session_path, params: { user: { email: 'nobody@test.com', password: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('nobody@test.com')
      end

      it 'falls through to normal login when password is provided' do
        post user_session_path, params: { user: { email: user.email, password: user.password } }

        expect(response).to redirect_to(authenticated_root_path)
      end
    end
  end
end
