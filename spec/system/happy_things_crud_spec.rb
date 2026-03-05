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
      expect(page).to have_content(happy_thing.title)

      click_link(happy_thing.title, match: :first)

      expect(page).to have_content(happy_thing.title.upcase)
      expect(page).to have_current_path(happy_thing_path(happy_thing))
    end

    it 'creates a new happy thing' do
      find('button.navbar-toggler').click

      expect(page).to have_link(href: new_happy_thing_path)

      click_link(href: new_happy_thing_path)

      expect(page).to have_selector('h1', text: I18n.t('happy_things.new_title').upcase)
      expect(page).to have_current_path(new_happy_thing_path)

      fill_in 'Name', with: 'cute mirror wtf'
      select 'Spiritual & Mind', from: 'happy_thing_category_id'
      attach_file 'happy_thing[photo]', Rails.root.join('spec/fixtures/test_image.jpg')

      expect do
        find('input[type="submit"]').click

        expect(page).to have_content(I18n.t('happy_things.created'))
      end.to change(HappyThing, :count).by(1)

      created_happy_thing = HappyThing.last
      expect(created_happy_thing.title).to eq('cute mirror wtf')
      expect(created_happy_thing.category.name).to eq('Spiritual & Mind')
      expect(created_happy_thing.photo.attached?).to be(true)
    end

    it 'updates a happy thing' do
      expect(page).to have_content(happy_thing.title)

      click_link(href: edit_happy_thing_path(happy_thing), match: :first)

      expect(page).to have_selector('h1', text: I18n.t('happy_things.edit_title').upcase)
      expect(page).to have_current_path(edit_happy_thing_path(happy_thing))

      fill_in 'Name', with: 'fresh new title'
      find('input[type="submit"]').click

      expect(page).to have_content(I18n.t('happy_things.updated'))
      expect(page).to have_content('FRESH NEW TITLE')
    end

    it 'destroys a happy thing' do
      expect(page).to have_content(happy_thing.title)

      click_link(href: edit_happy_thing_path(happy_thing), match: :first)

      expect(page).to have_selector('h1', text: I18n.t('happy_things.edit_title').upcase)
      expect(page).to have_current_path(edit_happy_thing_path(happy_thing))
      expect(page).to have_button("🗑️ #{I18n.t('happy_things.delete_button')}")

      expect do
        click_button('🗑️ Delete')

        expect(page).to have_content(I18n.t('happy_things.destroyed'))
      end.to change(HappyThing, :count).by(-1)

      expect(page).not_to have_content(happy_thing.title)
    end
  end
end
