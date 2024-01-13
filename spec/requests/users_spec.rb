require 'rails_helper'

RSpec.describe "Users", type: :request do
  before do
    @user = User.create!(first_name: 'Emma', email: 'emma@test.com', password: '123456')
    sign_in @user
  end

  describe "GET /index" do
    it "returns http success" do
      get "/users"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      user = User.create!(first_name: "Lea", email: "lea@test.com", password: "123456")
      get "/users/#{user.id}"
      expect(response).to have_http_status(:success)
    end
  end
end
