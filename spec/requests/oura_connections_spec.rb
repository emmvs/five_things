# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OuraConnections' do
  let(:user) { create(:user, confirmed_at: Time.current) }

  before do
    login_as(user, scope: :user)
  end

  describe 'GET /oura_connection/connect' do
    it 'shows the Oura connection page' do
      get connect_oura_connection_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Oura Ring Integration')
    end

    context 'when user is already connected' do
      before do
        user.update(
          oura_access_token: 'test_token',
          oura_refresh_token: 'refresh_token',
          oura_token_expires_at: 30.days.from_now
        )
        
        # Stub OuraService to avoid API calls
        allow_any_instance_of(OuraService).to receive(:connected?).and_return(true)
        allow_any_instance_of(OuraService).to receive(:latest_sleep_score).and_return(85)
        allow_any_instance_of(OuraService).to receive(:sleep_trend).and_return({
          average: 83,
          min: 71,
          max: 94,
          trend: 'improving'
        })
      end

      it 'shows connected status' do
        get connect_oura_connection_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Connected to Oura Ring')
      end
    end
  end

  describe 'GET /oura_connection/authorize' do
    it 'redirects to Oura OAuth page' do
      get authorize_oura_connection_path
      expect(response).to have_http_status(:redirect)
      expect(response.location).to include('cloud.ouraring.com/oauth/authorize')
      expect(response.location).to include('client_id=')
      expect(response.location).to include('state=')
    end
  end

  describe 'GET /oura_connection/callback' do
    let(:auth_code) { 'test_auth_code' }
    let(:state) { SecureRandom.hex(24) }

    context 'with valid state and successful token exchange' do
      before do
        # Mock session with stored state
        allow_any_instance_of(OuraConnectionsController).to receive(:session).and_return({ oura_oauth_state: state })
        
        # Mock the HTTParty response
        mock_response = double(
          'HTTParty::Response',
          success?: true,
          parsed_response: {
            'access_token' => 'new_access_token',
            'refresh_token' => 'new_refresh_token',
            'expires_in' => 2592000
          }
        )
        allow(HTTParty).to receive(:post).and_return(mock_response)
      end

      it 'exchanges code for token and saves to user' do
        expect do
          get callback_oura_connection_path, params: { code: auth_code, state: state }
        end.to change { user.reload.oura_access_token }.from(nil).to('new_access_token')

        expect(user.oura_refresh_token).to eq('new_refresh_token')
        expect(user.oura_token_expires_at).to be_present
        expect(response).to redirect_to(profile_path)
        expect(flash[:notice]).to include('Successfully connected to Oura')
      end
    end

    context 'with state mismatch' do
      before do
        allow_any_instance_of(OuraConnectionsController).to receive(:session).and_return({ oura_oauth_state: 'different_state' })
      end

      it 'redirects with error' do
        get callback_oura_connection_path, params: { code: auth_code, state: state }
        expect(response).to redirect_to(profile_path)
        expect(flash[:alert]).to include('State mismatch')
      end
    end

    context 'with error from Oura' do
      it 'redirects with error message' do
        get callback_oura_connection_path, params: { error: 'access_denied', error_description: 'User denied access' }
        expect(response).to redirect_to(profile_path)
        expect(flash[:alert]).to include('access_denied')
      end
    end
  end

  describe 'DELETE /oura_connection' do
    before do
      user.update(
        oura_access_token: 'test_token',
        oura_refresh_token: 'refresh_token',
        oura_token_expires_at: 30.days.from_now,
        oura_user_id: 'test_user_id'
      )
    end

    it 'disconnects Oura and clears tokens' do
      expect do
        delete oura_connection_path
      end.to change { user.reload.oura_access_token }.from('test_token').to(nil)

      expect(user.oura_refresh_token).to be_nil
      expect(user.oura_token_expires_at).to be_nil
      expect(user.oura_user_id).to be_nil
      expect(response).to redirect_to(edit_user_registration_path)
      expect(flash[:notice]).to include('disconnected')
    end
  end
end
