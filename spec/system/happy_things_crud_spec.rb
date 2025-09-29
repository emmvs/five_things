# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Happy Things CRUD', type: :system do # rubocop:disable Metrics/BlockLength
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

  describe 'CRUD operations' do # rubocop:disable Metrics/BlockLength
    it 'shows a happy thing' do
      expect(page).to have_content(happy_thing.title)

      click_link(happy_thing.title, match: :first)

      expect(page).to have_content(happy_thing.title.upcase)
      expect(page).to have_current_path(happy_thing_path(happy_thing))
    end

    it 'creates a new happy thing' do
      expect(page).to have_link(href: new_happy_thing_path)

      click_link(href: new_happy_thing_path)

      expect(page).to have_selector('h1', text: 'NEW HAPPY THING')
      expect(page).to have_current_path(new_happy_thing_path)

      fill_in 'Name', with: 'cute mirror wtf'

      # TODO: Update with visibility / location fix
      # check 'Share my location'
      # fill_in 'happy_thing_place', with: 'Berlin'
      select 'Spiritual & Mind', from: 'happy_thing_category_id'
      attach_file 'happy_thing[photo]', Rails.root.join('spec/fixtures/test_image.jpg')
      check 'Share my location'

      expect do
        click_on 'Create happy thing'

        expect(page).to have_content('Happy Thing was successfully created.')
      end.to change(HappyThing, :count).by(1)

      created_happy_thing = HappyThing.last
      expect(created_happy_thing.title).to eq('cute mirror wtf')
      expect(created_happy_thing.category.name).to eq('Spiritual & Mind')
      expect(created_happy_thing.photo.attached?).to be(true)
      # TODO: Update with location fix
      # expect(created_happy_thing.latitude).to be_present
      # expect(created_happy_thing.longitude).to be_present
    end

    it 'updates a happy thing' do
      expect(page).to have_content(happy_thing.title)

      click_link(href: edit_happy_thing_path(happy_thing), match: :first)

      expect(page).to have_selector('h1', text: 'EDIT HAPPY THING')
      expect(page).to have_current_path(edit_happy_thing_path(happy_thing))

      fill_in 'Name', with: 'fresh new title'
      click_button('Update happy thing')

      expect(page).to have_content('Yay! 🎉 Happy Thing was updated 🥰')
      expect(page).to have_content('fresh new title')
      expect(page).not_to have_content(happy_thing.title)
    end

    it 'destroys a happy thing' do
      expect(page).to have_content(happy_thing.title)

      click_link(href: edit_happy_thing_path(happy_thing), match: :first)

      expect(page).to have_selector('h1', text: 'EDIT HAPPY THING')
      expect(page).to have_current_path(edit_happy_thing_path(happy_thing))
      expect(page).to have_button('🗑️ Delete')

      expect do
        click_button('🗑️ Delete')

        expect(page).to have_content('Happy Thing was destroyed 😕')
      end.to change(HappyThing, :count).by(-1)

      expect(page).not_to have_content(happy_thing.title)
    end
  end
end
