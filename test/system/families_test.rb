require "application_system_test_case"

class FamiliesTest < ApplicationSystemTestCase
  setup do
    @family = families(:one)
  end

  test "visiting the index" do
    visit families_url
    assert_selector "h1", text: "Families"
  end

  test "should create family" do
    visit families_url
    click_on "New family"

    fill_in "City", with: @family.city
    fill_in "House number", with: @family.house_number
    fill_in "Phone1", with: @family.phone1
    fill_in "Phone2", with: @family.phone2
    fill_in "Reference name", with: @family.reference_name
    fill_in "State", with: @family.state
    fill_in "Street", with: @family.street
    click_on "Create Family"

    assert_text "Family was successfully created"
    click_on "Back"
  end

  test "should update Family" do
    visit family_url(@family)
    click_on "Edit this family", match: :first

    fill_in "City", with: @family.city
    fill_in "House number", with: @family.house_number
    fill_in "Phone1", with: @family.phone1
    fill_in "Phone2", with: @family.phone2
    fill_in "Reference name", with: @family.reference_name
    fill_in "State", with: @family.state
    fill_in "Street", with: @family.street
    click_on "Update Family"

    assert_text "Family was successfully updated"
    click_on "Back"
  end

  test "should destroy Family" do
    visit family_url(@family)
    click_on "Destroy this family", match: :first

    assert_text "Family was successfully destroyed"
  end
end
