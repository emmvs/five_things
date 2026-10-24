# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard', type: :request do
  let(:user) { create(:user) }

  before do
    allow(PoetryService).to receive(:call).and_return(nil)
    allow(QuoteService).to receive(:new).and_return(instance_double(QuoteService, call: nil))
    sign_in user, scope: :user
  end

  describe 'Through the years' do
    it 'shows HappyThings from today in earlier years' do
      create(:happy_thing, user:, title: 'Picnic by the lake', start_time: 2.years.ago)
      get authenticated_root_path
      expect(response.body).to include(I18n.t('dashboard.through_the_years'), 'Picnic by the lake')
    end

    it 'is hidden when there is nothing from earlier years' do
      create(:happy_thing, user:, title: 'Today only', start_time: Time.current)
      get authenticated_root_path
      expect(response.body).not_to include(I18n.t('dashboard.read_more'))
    end
  end
end
