# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Close Friends', type: :request do
  let(:publisher) { create(:user) }
  let(:signup_params) do
    { close_friends_subscriber: { name: 'Alex Friend', email: 'friend@example.com' } }
  end

  before do
    ENV['CLOSE_FRIENDS_PUBLISHER_USER_IDS'] = publisher.id.to_s
    ActionMailer::Base.deliveries.clear
  end

  describe 'GET /close_friends' do
    it 'shows the signup form' do
      get close_friends_root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('close_friends.join.title'))
    end

    it 'redirects publishers to the dashboard' do
      sign_in publisher

      get close_friends_root_path

      expect(response).to redirect_to(close_friends_dashboard_path)
    end
  end

  describe 'POST /close_friends/subscribers' do
    it 'creates a pending subscriber and sends confirmation email' do
      expect do
        post close_friends_subscribers_path, params: signup_params
      end.to change(CloseFriendsSubscriber, :count).by(1)

      subscriber = CloseFriendsSubscriber.last
      expect(subscriber.name).to eq('Alex Friend')
      expect(subscriber.email).to eq('friend@example.com')
      expect(response).to redirect_to(close_friends_root_path)
      expect(flash[:notice]).to eq(I18n.t('close_friends.subscribers.signup_notice'))
      expect do
        perform_enqueued_jobs
      end.to change { ActionMailer::Base.deliveries.size }.by(1)
    end

    it 'rejects invalid signup data' do
      post close_friends_subscribers_path,
           params: { close_friends_subscriber: { name: 'Al', email: 'not-an-email' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(CloseFriendsSubscriber.count).to eq(0)
    end

    it 'rejects names with links' do
      post close_friends_subscribers_path,
           params: { close_friends_subscriber: { name: 'www.spam.com', email: 'friend@example.com' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(CloseFriendsSubscriber.count).to eq(0)
    end
  end

  describe 'GET /close_friends/confirm' do
    it 'confirms a subscriber with a valid token' do
      subscriber = create(:close_friends_subscriber)
      token = CloseFriends::Token.generate(subscriber.id, CloseFriends::Token::CONFIRM)

      get close_friends_confirm_path(token: token)

      expect(response).to have_http_status(:success)
      expect(subscriber.reload.confirmed_at).to be_present
    end

    it 'returns not found with an invalid token' do
      get close_friends_confirm_path(token: 'invalid')
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /close_friends/unsubscribe' do
    it 'unsubscribes a deliverable subscriber' do
      subscriber = create(:close_friends_subscriber, :approved)
      token = CloseFriends::Token.generate(subscriber.id, CloseFriends::Token::UNSUBSCRIBE)

      get close_friends_unsubscribe_path(token: token)

      expect(response).to have_http_status(:success)
      expect(subscriber.reload.unsubscribed_at).to be_present
    end
  end

  describe 'GET /close_friends/issues/:id' do
    it 'shows a published issue publicly' do
      issue = create(:close_friends_issue, :published)

      get close_friends_issue_path(issue)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(issue.title)
    end

    it 'returns not found for a draft issue' do
      issue = create(:close_friends_issue)

      get close_friends_issue_path(issue)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'publisher dashboard' do
    before { sign_in publisher }

    it 'shows the dashboard for an allowlisted publisher' do
      create(:close_friends_subscriber, :approved)

      get close_friends_dashboard_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('1')
      expect(response.body).to include(I18n.t('nav.close_friends'))
    end

    it 'returns not found for a non-publisher' do
      sign_out publisher
      sign_in create(:user)

      get close_friends_dashboard_path

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'issue lifecycle' do
    before { sign_in publisher }

    it 'creates, publishes, and sends an issue to approved subscribers only' do
      approved = create(:close_friends_subscriber, :approved, email: 'approved@example.com')
      create(:close_friends_subscriber, :confirmed, email: 'pending@example.com')

      post close_friends_issues_path, params: {
        close_friends_issue: { title: 'Hello', body: "Line one\nLine two" }
      }
      issue = CloseFriendsIssue.last
      expect(response).to redirect_to(edit_close_friends_issue_path(issue))

      post publish_close_friends_issue_path(issue)
      expect(issue.reload.published_at).to be_present

      expect do
        post send_issue_close_friends_issue_path(issue)
      end.to have_enqueued_mail(CloseFriendsMailer, :issue).once

      expect(issue.reload.sent_at).to be_present
      expect(approved.reload.unsubscribed_at).to be_nil
    end
  end

  describe 'subscriber approval' do
    before { sign_in publisher }

    it 'approves a pending subscriber' do
      subscriber = create(:close_friends_subscriber, :confirmed)

      post approve_close_friends_subscriber_path(subscriber)

      expect(response).to redirect_to(close_friends_dashboard_path)
      expect(subscriber.reload.approved_at).to be_present
    end

    it 'rejects a pending subscriber by removing the record' do
      subscriber = create(:close_friends_subscriber, :confirmed)

      expect do
        delete reject_close_friends_subscriber_path(subscriber)
      end.to change(CloseFriendsSubscriber, :count).by(-1)
    end
  end
end
