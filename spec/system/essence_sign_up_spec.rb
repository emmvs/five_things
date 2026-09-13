# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Essence sign up', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    ActionMailer::Base.deliveries.clear
  end

  it 'walks through the animated signup flow' do
    visit the_essence_sign_up_path

    expect(page).to have_css('[data-essence-signup-target="step1"]')

    fill_in 'essence_subscriber_name', with: 'Emma'
    find('[data-action="click->essence-signup#advanceFromName"]').click

    expect(page).to have_css('[data-essence-signup-target="step2"]:not(.d-none)', wait: 10)

    fill_in 'essence_subscriber_email', with: 'emma-signup@example.com'
    find('[data-action="click->essence-signup#submitSignup"]').click

    expect(page).to have_text(I18n.t('essence.sign_up.farewell'), wait: 15)
    expect(EssenceSubscriber.find_by(email: 'emma-signup@example.com')).to be_present
  end
end
