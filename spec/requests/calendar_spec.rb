# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Calendar', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get calendar_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Tue')
    end
  end
end
