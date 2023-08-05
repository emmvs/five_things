require "application_system_test_case"
include Warden::Test::Helpers

class HappyThingsTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers  # Add this line to include the Devise integration helpers

  setup do
    @happy_thing = happy_things(:one) # Reference to the first fixture happy_thing
    @user = users(:one)
    login_as @user
  end

  test "Creating a new happy thing" do
    # When we visit the HappyThings#index page
    # we expect to see a title with the text "HappyThings"
    visit happy_things_path
    assert_selector "h1", text: "Happy Things"

    # When we click on the link with the text "New happy thing"
    # we expect to land on a page with the title "New happy thing"
    click_on "New happy thing"
    assert_selector "h1", text: "New happy thing"

    # When we fill in the name input with "Capybara happy thing"
    # and we click on "Create HappyThing"
    fill_in "Name", with: "Create happy thing"
    click_on "Create happy thing"

    # We expect to be back on the page with the title "Happy Things"
    # and to see our "Capybara happy thing" added to the list
    assert_selector "h1", text: "Happy Things"
    assert_text "Happy Thing was successfully created."
  end

  test "Showing a happy thing" do
    visit happy_things_path
    click_link @happy_thing.title

    assert_selector "h1", text: @happy_thing.title
  end

  test "Updating a happy thing" do
    visit happy_things_path
    assert_selector "h1", text: "Happy Things"

    # click_on "Edit", match: :one
    # assert_selector "h1", text: "Edit happy thing"
    find(".edit-link", match: :first).click
    assert_selector "h1", text: "Edit happy thing"

    fill_in "happy_thing[title]", with: "Updated happy thing"
    click_on "Update happy thing"

    assert_selector "h1", text: "Happy Things"
    assert_text "Updated happy thing"
  end

  test "Destroying a happy thing" do
    visit happy_things_path
    assert_text @happy_thing.title

    click_on "Delete", match: :first
    assert_no_text @happy_thing.title
  end
end
