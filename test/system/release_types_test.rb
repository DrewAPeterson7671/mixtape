require "application_system_test_case"

class ReleaseTypesTest < ApplicationSystemTestCase
  setup do
    @release_type = release_types(:one)
  end

  test "visiting the index" do
    visit release_types_url
    assert_selector "h1", text: "Release types"
  end

  test "should create release type" do
    visit release_types_url
    click_on "New release type"

    fill_in "Name", with: @release_type.name
    click_on "Create Release type"

    assert_text "Release type was successfully created"
    click_on "Back"
  end

  test "should update Release type" do
    visit release_type_url(@release_type)
    click_on "Edit this release type", match: :first

    fill_in "Name", with: @release_type.name
    click_on "Update Release type"

    assert_text "Release type was successfully updated"
    click_on "Back"
  end

  test "should destroy Release type" do
    visit release_type_url(@release_type)
    click_on "Destroy this release type", match: :first

    assert_text "Release type was successfully destroyed"
  end
end
