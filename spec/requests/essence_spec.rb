# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Essence newsletter', type: :request do
  include ActiveJob::TestHelper

  let(:signup_params) do
    { essence_subscriber: { name: 'Emma Friend', email: 'emma@example.com' } }
  end

  before do
    ActionMailer::Base.deliveries.clear
  end

  describe 'GET /the_essence/sign_up' do
    it 'shows the signup page' do
      get the_essence_sign_up_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('essence.sign_up.greeting'))
    end
  end

  describe 'POST /the_essence/subscribers' do
    it 'creates a pending subscriber and sends confirmation email' do
      expect do
        post the_essence_subscribers_path, params: signup_params, as: :json
      end.to change(EssenceSubscriber, :count).by(1)

      subscriber = EssenceSubscriber.last
      expect(subscriber.name).to eq('Emma Friend')
      expect(subscriber.email).to eq('emma@example.com')
      expect(subscriber.confirmed_at).to be_nil
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq(I18n.t('essence.sign_up.farewell'))

      perform_enqueued_jobs
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end

    it 'returns the same farewell for an already confirmed email' do
      create(:essence_subscriber, :confirmed, email: 'emma@example.com')

      post the_essence_subscribers_path, params: signup_params, as: :json

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq(I18n.t('essence.sign_up.farewell'))
      perform_enqueued_jobs
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it 'rejects invalid signup data' do
      post the_essence_subscribers_path,
           params: { essence_subscriber: { name: 'Al', email: 'not-an-email' } },
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(EssenceSubscriber.count).to eq(0)
    end

    it 'rejects names with links' do
      post the_essence_subscribers_path,
           params: { essence_subscriber: { name: 'www.spam.com', email: 'emma@example.com' } },
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(EssenceSubscriber.count).to eq(0)
    end

    it 'allows resubscribing after unsubscribe' do
      create(:essence_subscriber, :unsubscribed, email: 'emma@example.com')

      expect do
        post the_essence_subscribers_path, params: signup_params, as: :json
      end.not_to change(EssenceSubscriber, :count)

      subscriber = EssenceSubscriber.find_by(email: 'emma@example.com')
      expect(subscriber.unsubscribed_at).to be_nil
      expect(subscriber.confirmed_at).to be_nil
    end
  end

  describe 'confirmation flow' do
    it 'accepts a subscriber after visiting the prompt and posting confirmation' do
      subscriber = create(:essence_subscriber)
      token = Essence::Token.generate(subscriber.id, Essence::Token::CONFIRM)

      get the_essence_confirm_path(token:)
      expect(response).to have_http_status(:success)
      expect(subscriber.reload.confirmed_at).to be_nil

      post the_essence_confirm_path, params: { token: }
      expect(response).to redirect_to(the_essence_welcome_path)
      follow_redirect!
      expect(response.body).to include(I18n.t('essence.subscribers.welcome_title'))
      expect(subscriber.reload.confirmed_at).to be_present
    end

    it 'returns not found with an invalid token' do
      get the_essence_confirm_path(token: 'invalid')
      expect(response).to have_http_status(:not_found)

      post the_essence_confirm_path, params: { token: 'invalid' }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found when confirming with the wrong token purpose' do
      subscriber = create(:essence_subscriber)
      token = Essence::Token.generate(subscriber.id, Essence::Token::UNSUBSCRIBE)

      post the_essence_confirm_path, params: { token: }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'unsubscribe flow' do
    it 'unsubscribes a deliverable subscriber' do
      subscriber = create(:essence_subscriber, :confirmed)
      token = Essence::Token.generate(subscriber.id, Essence::Token::UNSUBSCRIBE)

      get the_essence_unsubscribe_path(token:)
      expect(response).to have_http_status(:success)
      expect(subscriber.reload.unsubscribed_at).to be_nil

      post the_essence_unsubscribe_path, params: { token: }
      expect(response).to redirect_to(the_essence_unsubscribed_done_path)
      follow_redirect!
      expect(subscriber.reload.unsubscribed_at).to be_present
    end
  end
end
