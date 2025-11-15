# frozen_string_literal: true

class OuraConnectionsController < ApplicationController
  before_action :authenticate_user!

  OURA_AUTHORIZE_URL = 'https://cloud.ouraring.com/oauth/authorize'
  OURA_TOKEN_URL     = 'https://api.ouraring.com/oauth/token'

  def connect
    # Show the Oura settings page
  end

  def authorize
    state = SecureRandom.hex(24)
    session[:oura_oauth_state] = state

    redirect_uri = callback_oura_connection_url(host: request.host_with_port, protocol: request.protocol.sub('://', ''))
    Rails.logger.info("Oura OAuth redirect_uri: #{redirect_uri}")

    query = {
      response_type: 'code',
      client_id: ENV.fetch('OURA_CLIENT_ID'),
      redirect_uri:,
      scope: requested_scopes,
      state:
    }.to_query

    oauth_url = "#{OURA_AUTHORIZE_URL}?#{query}"
    Rails.logger.info("Redirecting to Oura: #{oauth_url}")

    redirect_to oauth_url, allow_other_host: true
  end

  def callback
    Rails.logger.info("Full request URL: #{request.original_url}")
    Rails.logger.info("Query string: #{request.query_string}")
    Rails.logger.info("All params: #{request.query_parameters.inspect}")
    Rails.logger.info("Callback params: #{params.inspect}")
    Rails.logger.info("Session state: #{session[:oura_oauth_state]}")
    Rails.logger.info("Params state: #{params[:state]}")

    if params[:error].present?
      flash[:alert] = "Oura error: #{params[:error]} - #{params[:error_description]}"
      redirect_to profile_path
      return
    end

    unless params[:state].present?
      flash[:alert] = 'Missing state parameter - authorization may not have completed'
      redirect_to profile_path
      return
    end

    stored_state = session.delete(:oura_oauth_state)
    if params[:state] != stored_state
      flash[:alert] =
        "State mismatch (expected: #{stored_state}, got: #{params[:state]}). Possible CSRF or session issue."
      redirect_to profile_path
      return
    end

    token_response = exchange_code_for_token(params[:code])

    if token_response['error']
      flash[:alert] = "Token exchange failed: #{token_response['error_description']}"
    else
      # Store Oura tokens
      current_user.update(
        oura_access_token: token_response['access_token'],
        oura_refresh_token: token_response['refresh_token'],
        oura_token_expires_at: token_response['expires_in'].seconds.from_now
      )

      Rails.logger.info("Oura token response: #{token_response.inspect}")
      flash[:notice] = 'Successfully connected to Oura! 💍'
    end
    redirect_to profile_path
  end

  def destroy
    current_user.update(
      oura_access_token: nil,
      oura_refresh_token: nil,
      oura_token_expires_at: nil,
      oura_user_id: nil
    )

    flash[:notice] = 'Oura Ring disconnected successfully'
    redirect_to edit_user_registration_path
  end

  private

  def requested_scopes
    %w[daily heartrate workout session tag].join(' ')
  end

  def exchange_code_for_token(code)
    redirect_uri = callback_oura_connection_url(host: request.host_with_port, protocol: request.protocol.sub('://', ''))

    response = HTTParty.post(
      OURA_TOKEN_URL,
      body: {
        grant_type: 'authorization_code',
        code:,
        redirect_uri:,
        client_id: ENV.fetch('OURA_CLIENT_ID'),
        client_secret: ENV.fetch('OURA_CLIENT_SECRET')
      },
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
    )

    response.parsed_response
  rescue StandardError => e
    { 'error' => 'network_error', 'error_description' => e.message }
  end
end
