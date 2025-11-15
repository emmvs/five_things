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
    expect(page).to have_content('Signed in successfully.', wait: 2)

    find('button.navbar-toggler').click
    expect(page).to have_link(href: settings_path)

    click_link(href: settings_path)

    expect(page).to have_link(I18n.t('account.delete.unhappy_button'), wait: 2)

    click_link I18n.t('account.delete.unhappy_button')

    expect(page).to have_content(I18n.t('account.delete.page_title'), wait: 2)

    page.evaluate_script('window.confirm = function() { return true; }')
    click_on I18n.t('account.delete.delete_button')

    expect(page).to have_current_path(root_path, wait: 2)
    expect(page).to have_content(I18n.t('devise.registrations.destroyed'), wait: 2)
    expect(User.find_by(id: user.id)).to be_nil
  end
end
