# frozen_string_literal: true

require "application_system_test_case"

class OtherPartNumbersTest < ApplicationSystemTestCase
  setup do
    @other_part_number = other_part_numbers(:red_button_meco)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit part_other_part_numbers_url(@other_part_number.part)
    assert_selector "h1", text: "Other Part Numbers"
  end

  test "should create other part number" do
    visit parts_url

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @other_part_number.part.mfg_part_number, :enter

    assert_no_text "gbc101"
    assert_text @other_part_number.part.mfg_part_number

    click_on @other_part_number.part.org_part_number

    page.find("a", exact_text: "Add").click

    select @other_part_number.company_type, from: "Type"
    select @other_part_number.company.name, from: "Company"
    fill_in "Part number", with: @other_part_number.part_number
    click_on "Create Other part number"

    assert_text "Other part number was successfully created"
  end

  test "should create other part number with other type" do
    visit parts_url

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @other_part_number.part.mfg_part_number, :enter

    assert_no_text "gbc101"
    assert_text @other_part_number.part.mfg_part_number

    click_on @other_part_number.part.org_part_number

    click_on "Add"

    select "Other", from: "Type"
    fill_in "Company", with: "MOCO"
    fill_in "Part number", with: @other_part_number.part_number
    click_on "Create Other part number"

    assert_text "Other part number was successfully created"
  end

  test "should update Other part number" do
    visit parts_url

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @other_part_number.part.mfg_part_number, :enter

    assert_no_text "gbc101"
    assert_text @other_part_number.part.mfg_part_number

    click_on @other_part_number.part.org_part_number

    within("table#opn") do
      click_on "Edit", match: :first
    end

    select @other_part_number.company_type, from: "Type"
    select @other_part_number.company.name, from: "Company"
    fill_in "Part number", with: @other_part_number.part_number
    click_on "Update Other part number"

    assert_text "Other part number was successfully updated"
  end

  test "should destroy Other part number" do
    visit parts_url

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @other_part_number.part.mfg_part_number, :enter

    assert_no_text "gbc101"
    assert_text @other_part_number.part.mfg_part_number

    click_on @other_part_number.part.org_part_number

    within("table#opn") do
      accept_confirm do
        click_on "Delete", match: :first
      end
    end

    assert_text "Other part number was successfully destroyed"
  end
end
