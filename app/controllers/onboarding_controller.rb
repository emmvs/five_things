# frozen_string_literal: true

class OnboardingController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  before_action :disable_navbar

  def new
    # Show onboarding flow
  end

  def create_guest_session
    session[:guest_onboarding] = {
      happy_thing: params[:happy_thing],
      emoji: params[:emoji],
      name: params[:name],
      created_at: Time.current
    }

    render json: { success: true, redirect_url: root_path }
  end
end
