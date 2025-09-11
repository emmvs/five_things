# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Friends', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get friends_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('My Friends')
    end
  end
end
