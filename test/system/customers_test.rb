# frozen_string_literal: true

require "application_system_test_case"

class CustomersTest < ApplicationSystemTestCase
  setup do
    @customer = customers(:wile)
    @customer2 = customers(:unassociated)
    @customer3 = customers(:zhent)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit customers_url
    assert_selector "h1", text: "Customers"
  end

  test "should create customer" do
    visit customers_url
    click_on "New Customer"

    fill_in "Name", with: "MOCO"
    click_on "Create Customer"

    assert_text "Customer was successfully created"
    click_on "Back"
  end

  test "should update Customer" do
    visit customer_url(@customer)
    click_on "Edit This Customer", match: :first

    fill_in "Name", with: @customer.name
    click_on "Update Customer"

    assert_text "Customer was successfully updated"
    click_on "Back"
  end

  test "should not destroy Customer with associated jobs" do
    visit customer_url(@customer)
    accept_confirm do
      click_on "Destroy This Customer", match: :first
    end

    assert_text "Customer cannot be deleted while it has associated jobs."
  end

  test "should destroy Customer without associated jobs" do
    visit customer_url(@customer2)
    accept_confirm do
      click_on "Destroy This Customer", match: :first
    end

    assert_text "Customer was successfully destroyed"
  end

  test "should search and filter the index" do
    visit customers_url
    assert_text @customer.name

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @customer.name, :enter

    assert_no_text @customer2.name
    assert_text @customer.customer_address&.address_1

    click_on "\u2716", match: :first

    assert_text @customer2.name
    assert_text @customer.name

    click_on "Filters", match: :first

    fields = [ ["name", @customer.name], ["address", @customer.customer_address&.address_1], ["city", @customer.customer_address&.city],
               ["state", @customer.customer_address&.state], ["zip_code", @customer.customer_address&.zip_code], ["phone_number", @customer.phone_number] ]

    fields.each do |field|
      if field[0] == "state"
        select @customer.customer_address&.state, from: field[0]
      else
        fill_in field[0], with: field[1]
      end
      click_on "Apply", match: :first

      assert_text @customer.name
      assert_no_text @customer2.name

      click_on "Reset", match: :first

      assert_text @customer.name
      assert_text @customer2.name
    end

    assert_text @customer.name
    assert_text @customer2.name
  end

  test "should sort index by column" do
    visit customers_url

    assert_text @customer.name
    assert_text @customer3.name

    sort_array = [["Name", [@customer3.name, @customer.name]], ["Address", [@customer3.name, @customer.name]], ["City", [@customer.name, @customer3.name]],
                  ["State", [@customer3.name, @customer.name]], ["Zip Code", [@customer.name, @customer3.name]], ["Phone Number", [@customer3.name, @customer.name]]]
    sort_array.each do |sort|
      header = find("th[data-action='click->table-order#sort']", text: sort[0], match: :first, wait: 5)
      header.click
      assert_text(/#{sort[1][0]}.*#{sort[1][1]}/m, wait: 5)
      header.click
      assert_text(/#{sort[1][1]}.*#{sort[1][0]}/m, wait: 5)
    end
  end

  test "should not throw errors when exporting" do
    visit customers_url
    click_on "CSV Export"
  end
end
