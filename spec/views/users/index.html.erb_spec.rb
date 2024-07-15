# frozen_string_literal: true

# require 'rails_helper'

# RSpec.describe "users/index", type: :view do
#   let(:user) { create(:user) }
#   let(:friends) { create_list(:user, 3) }

#   before(:each) do
#     allow(view).to receive(:current_user).and_return(user)
#     # @users = create_list(:user, 5)
#     assign(:users, create_list(:user, 5))
#     allow(user).to receive(:all_friends).and_return(friends)
#   end

#   it "renders a list of friends" do
#     render

#     friends.each do |friend|
#       expect(rendered).to match(friend.first_name)
#     end
#   end

#   it "renders a list of users" do
#     render

#     assigns(:users).each do |user|
#       expect(rendered).to match(user.first_name)
#     end
#   end

#   it "renders action buttons based on friendship status" do
#     render

#     # Example: Test for the presence of 'Add Friend' button
#     # Adjust the test according to the actual buttons and logic in your view
#     # expect(rendered).to have_selector("input[type=submit][value='Add Friend']")
#     expect(rendered).to have_selector(".btn.button--primary", text: 'Add Friend')
#   end
# end
