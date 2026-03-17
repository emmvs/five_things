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
    expect(User.find_by(id: user.id)).to be_present
    expect(page).to have_content(I18n.t('devise.sessions.signed_in'))

    find('button.navbar-toggler').click
    expect(page).to have_link(href: settings_path)

    click_link(href: settings_path)

    expect(page).to have_button(I18n.t('settings.danger_zone.delete_button'))

    accept_confirm(I18n.t('settings.danger_zone.delete_confirmation')) do
      click_button I18n.t('settings.danger_zone.delete_button')
    end

    expect(page).to have_current_path(root_path)
    expect(User.find_by(id: user.id)).to be_nil
  end
end
