# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Happy Things CRUD', type: :system do
  let(:user) { create(:user) }
  let!(:category) { create(:category, name: 'General') }
  let!(:category2) { create(:category, name: 'Spiritual & Mind') }
  let!(:happy_thing) { create(:happy_thing, user:) }

  before do
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
  end

  describe 'CRUD operations' do
    it 'shows a happy thing' do
      expect(page).to have_content(happy_thing.title, wait: 5)

      click_link(happy_thing.title, match: :first)

      expect(page).to have_content(happy_thing.title.upcase)
      expect(page).to have_current_path(happy_thing_path(happy_thing), wait: 5)
    end

    it 'creates a new happy thing' do
      find('button.navbar-toggler', wait: 5).click

      expect(page).to have_link(href: new_happy_thing_path, wait: 5)

      click_link(href: new_happy_thing_path)

      expect(page).to have_selector('h1', text: 'NEW HAPPY THING', wait: 5)
      expect(page).to have_current_path(new_happy_thing_path, wait: 5)

      fill_in 'What made you smile today?', with: 'cute mirror wtf'
      select 'Spiritual & Mind', from: 'happy_thing_category_id'
      attach_file 'happy_thing[photo]', Rails.root.join('spec/fixtures/test_image.jpg'), visible: false
      check 'Save my location for this happy thing'

      expect do
        click_on 'Create happy thing'

        expect(page).to have_content('Happy Thing was successfully created.')
      end.to change(HappyThing, :count).by(1)

      created_happy_thing = HappyThing.last
      expect(created_happy_thing.title).to eq('cute mirror wtf')
      expect(created_happy_thing.category.name).to eq('Spiritual & Mind')
      expect(created_happy_thing.photo.attached?).to be(true)
    end

    it 'updates a happy thing' do
      expect(page).to have_content(happy_thing.title, wait: 5)

      click_link(href: edit_happy_thing_path(happy_thing), match: :first)

      expect(page).to have_selector('h1', text: 'EDIT HAPPY THING', wait: 5)
      expect(page).to have_current_path(edit_happy_thing_path(happy_thing))

      fill_in 'What made you smile today?', with: 'fresh new title'
      click_button('Submit Changes')

      expect(page).to have_content('Yay! 🎉 Happy Thing was updated 🥰')
      expect(page).to have_content('fresh new title')
      expect(page).not_to have_content(happy_thing.title, wait: 5)
    end

    it 'destroys a happy thing' do
      expect(page).to have_content(happy_thing.title, wait: 5)

      click_link(href: edit_happy_thing_path(happy_thing), match: :first)

      expect(page).to have_selector('h1', text: 'EDIT HAPPY THING', wait: 5)
      expect(page).to have_current_path(edit_happy_thing_path(happy_thing))
      expect(page).to have_button('🗑️ Delete', wait: 5)

      expect do
        accept_confirm do
          click_button('🗑️ Delete')
        end

        expect(page).to have_content('Happy Thing was destroyed 😕', wait: 5)
      end.to change(HappyThing, :count).by(-1)

      expect(page).not_to have_content(happy_thing.title, wait: 5)
    end
  end
end
