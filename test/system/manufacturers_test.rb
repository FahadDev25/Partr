# frozen_string_literal: true

require "application_system_test_case"

class ManufacturersTest < ApplicationSystemTestCase
  setup do
    @manufacturer = manufacturers(:acme)
    @lum = manufacturers(:lumco)
    @useless = manufacturers(:makes_nothing)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit manufacturers_url
    assert_selector "h1", text: "Manufacturers"
  end

  test "should create manufacturer" do
    visit manufacturers_url
    click_on "New Manufacturer"

    fill_in "Name", with: "Test"
    select @manufacturer.vendor.name, from: "Vendor"
    click_on "Create Manufacturer"

    assert_text "Manufacturer was successfully created"
    click_on "Back"
  end

  test "should update Manufacturer" do
    visit manufacturer_url(@manufacturer)
    click_on "Edit This Manufacturer", match: :first

    fill_in "Name", with: "Test"
    select @manufacturer.vendor.name, from: "Vendor"
    click_on "Update Manufacturer"

    assert_text "Manufacturer was successfully updated"
    click_on "Back"
  end

  test "should destroy Manufacturer with no associated parts" do
    visit manufacturer_url(@useless)
    accept_confirm do
      click_on "Destroy This Manufacturer", match: :first
    end

    assert_text "Manufacturer was successfully destroyed"
  end

  test "should not destroy Manufacturer with associated parts" do
    visit manufacturer_url(@manufacturer)
    accept_confirm do
      click_on "Destroy This Manufacturer", match: :first
    end

    assert_text "Cannot destroy Manufacturer with associated parts."
  end

  test "should search and filter the index" do
    visit manufacturers_url
    assert_text @manufacturer.name
    assert_text @lum.name

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @manufacturer.name, :enter

    assert_no_text @lum.name
    assert_text @manufacturer.vendor.name

    click_on "\u2716", match: :first

    assert_text @lum.name
    assert_text @manufacturer.name

    click_on "Filters", match: :first

    fields = [ ["name", @manufacturer.name], ["vendor", @manufacturer.vendor.name] ]

    fields.each do |field|
      if field[0] == "vendor"
        select @manufacturer.vendor.name, from: field[0]
      else
        fill_in field[0], with: field[1]
      end
      click_on "Apply", match: :first

      assert_text @manufacturer.name
      assert_no_text @lum.name

      click_on "Reset", match: :first

      assert_text @manufacturer.name
      assert_text @lum.name
    end

    assert_text @manufacturer.name
    assert_text @lum.name
  end

  test "should sort index by column" do
    visit manufacturers_url

    assert_text @manufacturer.name
    assert_text @lum.name

    sort_array = [["Name", [@manufacturer.name, @lum.name]], ["Vendor", [@lum.name, @manufacturer.name]]]
    sort_array.each do |sort|
      header = find("th[data-action='click->table-order#sort']", text: sort[0], match: :first, wait: 5)
      header.click
      assert_text(/#{sort[1][0]}.*#{sort[1][1]}/m, wait: 5)
      header.click
      assert_text(/#{sort[1][1]}.*#{sort[1][0]}/m, wait: 5)
    end
  end

  test "should not throw errors when exporting" do
    visit manufacturers_url
    click_on "CSV Export"
  end
end
