# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Account Deletion', type: :system do
  let(:user) { create(:user) }

  before do
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
  end

  it 'allows users to delete their account', js: true do
    visit edit_user_registration_path

    expect(User.find_by(id: user.id)).to be_present

    accept_confirm do
      click_on 'Cancel my account'
    end

    expect(page).to have_current_path(root_path)
    expect(page).to have_content('Bye! Your account has been successfully cancelled. We hope to see you again soon.')
    expect(User.find_by(id: user.id)).to be_nil
  end
end
