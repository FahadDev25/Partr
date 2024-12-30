# frozen_string_literal: true

require "application_system_test_case"

class VendorsTest < ApplicationSystemTestCase
  setup do
    @vendor = vendors(:warner_bros)
    @empty = vendors(:empty)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit vendors_url
    assert_selector "h1", text: "Vendors"
  end

  test "should create vendor" do
    visit vendors_url
    click_on "New Vendor"

    fill_in "Name", with: "#{@vendor.name}test"
    click_on "Create Vendor"

    assert_text "Vendor was successfully created"
    click_on "Back"
  end

  test "should update Vendor" do
    visit vendor_url(@vendor)
    click_on "Edit This Vendor", match: :first

    fill_in "Name", with: @vendor.name
    click_on "Update Vendor"

    assert_text "Vendor was successfully updated"
    click_on "Back"
  end

  test "should destroy Vendor with no associated Manufacturers or Orders" do
    visit vendor_url(@empty)
    accept_confirm do
      click_on "Destroy This Vendor", match: :first
    end

    assert_text "Vendor was successfully destroyed"
  end

  test "should not destroy Vendor with associated Manufacturers or Orders" do
    visit vendor_url(@vendor)
    accept_confirm do
      click_on "Destroy This Vendor", match: :first
    end

    assert_text "Cannot destroy Vendor with associate Manufacturers or Orders."
  end

  test "should search and filter the index" do
    visit vendors_url
    assert_text @vendor.name

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @vendor.name, :enter

    assert_no_text @empty.name
    assert_text @vendor.vendor_address&.address_1

    click_on "\u2716", match: :first

    assert_text @empty.name
    assert_text @vendor.name

    click_on "Filters", match: :first

    fields = [ ["name", @vendor.name], ["address", @vendor.vendor_address&.address_1], ["city", @vendor.vendor_address&.city], ["state", @vendor.vendor_address&.state],
      ["zip_code", @vendor.vendor_address&.zip_code], ["phone_number", @vendor.phone_number], ["representative", @vendor.representative] ]

    fields.each do |field|
      if field[0] == "state"
        select @vendor.vendor_address&.state, from: field[0]
      else
        fill_in field[0], with: field[1]
      end
      click_on "Apply", match: :first

      assert_text @vendor.name
      assert_no_text @empty.name

      click_on "Reset", match: :first

      assert_text @vendor.name
      assert_text @empty.name
    end

    assert_text @vendor.name
    assert_text @empty.name
  end

  test "should sort index by column" do
    visit vendors_url

    assert_text @vendor.name
    assert_text @empty.name

    sort_array = [["Name", [@empty.name, @vendor.name]], ["Address", [@vendor.name, @empty.name]], ["City", [@vendor.name, @empty.name]],
                  ["State", [@vendor.name, @empty.name]], ["Zip Code", [@vendor.name, @empty.name]], ["Phone Number", [@vendor.name, @empty.name]],
                  ["Representative", [@vendor.name, @empty.name]]]
    sort_array.each do |sort|
      header = find("th[data-action='click->table-order#sort']", text: sort[0], match: :first, wait: 5)
      header.click
      assert_text(/#{sort[1][0]}.*#{sort[1][1]}/m, wait: 5)
      header.click
      assert_text(/#{sort[1][1]}.*#{sort[1][0]}/m, wait: 5)
    end
  end

  test "should not throw errors when exporting" do
    visit vendors_url
    click_on "CSV Export"
  end
end
