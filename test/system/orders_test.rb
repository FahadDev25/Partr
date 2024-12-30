# frozen_string_literal: true

require "application_system_test_case"

class OrdersTest < ApplicationSystemTestCase
  setup do
    attachments(:one).file.attach(io: File.open("test/fixtures/files/slip1.png"), filename: "slip1.png", content_type: "image/png")
    @order = orders(:button_order)
    @one_part = orders(:one_part)
    @empty_order = orders(:empty_order)
    @user = users(:admin)
    @empty_vendor = vendors(:empty)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit team_orders_url(@team)
    assert_selector "h1", text: "Orders"
  end

  test "should create itemized order" do
    visit team_orders_url(@team)
    click_on "New Order"

    assert_field("order[tax_rate]", with: @team.default_tax_rate)

    fill_in "Order date", with: @order.order_date
    assert_no_text @empty_vendor.name
    assert_text @order.vendor.name
    tom_select @order.vendor.name, from: "Vendor"
    tom_select @order.payment_method, from: "Payment method"
    fill_in "Freight cost", with: @order.freight_cost
    fill_in "Tax rate", with: @order.tax_rate
    fill_in "Notes", with: @order.notes
    within "div#ship_to_fields" do
      fill_in "Address 1", with: @order.ship_to&.address_1
      fill_in "Address 2", with: @order.ship_to&.address_2
      fill_in "City", with: @order.ship_to&.city
      select @order.ship_to&.state, from: "State"
      fill_in "Zip code", with: @order.ship_to&.zip_code
    end
    within "div#billing_address_fields" do
      fill_in "Address 1", with: @order.billing_address&.address_1
      fill_in "Address 2", with: @order.billing_address&.address_2
      fill_in "City", with: @order.billing_address&.city
      select @order.billing_address&.state, from: "State"
      fill_in "Zip code", with: @order.billing_address&.zip_code
    end
    check "order[for_all]"
    click_on "Create Order"

    assert_text "Order was successfully created"
    order = Order.last
    assert_equal 33.50, order.parts_cost
    assert_equal 1.675, order.tax_total

    visit job_url(@order.job)
    assert_text "3/3"
    assert_text "4/3"

    click_on "Back"
  end

  test "should create totals order" do
    visit team_orders_url(@team)
    click_on "New Order"

    fill_in "Order date", with: @order.order_date
    assert_no_text @empty_vendor.name
    assert_text @order.vendor.name
    tom_select @order.vendor.name, from: "Vendor"
    tom_select @order.payment_method, from: "Payment method"
    fill_in "Quote number", with: @order.quote_number
    fill_in "FOB", with: @order.fob
    fill_in "Freight cost", with: 3.50
    find("#fields_toggle").trigger("click") # check "fields_toggle"
    assert_text "Total Part Cost"
    fill_in "Total Part Cost", with: 3.50
    fill_in "Total Tax", with: 3.50
    click_on "Create Order"

    assert_text "Order was successfully created"

    order = Order.last
    assert_equal 3.50, order.parts_cost
    assert_equal 3.50, order.tax_total
    assert_equal 3.50, order.freight_cost
    assert_equal 10.50, order.total_cost

    click_on "Back"
  end

  test "should update Order" do
    visit order_url(@order)
    click_on "Edit This Order", match: :first

    select @order.job.name, from: "Job"
    fill_in "Order date", with: @order.order_date
    tom_select @order.vendor.name, from: "Vendor"
    tom_select @order.payment_method, from: "Payment method"
    fill_in "Freight cost", with: 3.50
    fill_in "Total Part Cost", with: 3.50
    fill_in "Total tax", with: 3.50
    fill_in "Quote number", with: @order.quote_number
    fill_in "FOB", with: @order.fob
    within "div#ship_to_fields" do
      fill_in "Address 1", with: @order.ship_to&.address_1
      fill_in "Address 2", with: @order.ship_to&.address_2
      fill_in "City", with: @order.ship_to&.city
      select @order.ship_to&.state, from: "State"
      fill_in "Zip code", with: @order.ship_to&.zip_code
    end
    within "div#billing_address_fields" do
      fill_in "Address 1", with: @order.billing_address&.address_1
      fill_in "Address 2", with: @order.billing_address&.address_2
      fill_in "City", with: @order.billing_address&.city
      select @order.billing_address&.state, from: "State"
      fill_in "Zip code", with: @order.billing_address&.zip_code
    end
    click_on "Update Order"

    assert_text "Order was successfully updated"

    @order.reload

    assert_equal 3.50, @order.parts_cost
    assert_equal 3.50, @order.tax_total
    assert_equal 3.50, @order.freight_cost
    assert_equal 10.50, @order.total_cost

    click_on "Back"
  end

  test "should destroy Order with no associated Shipments" do
    visit order_url(@empty_order)
    accept_confirm do
      click_on "Destroy This Order", match: :first
    end

    assert_text "Order was successfully destroyed"
  end

  test "should not destroy Order with associated Shipments" do
    visit order_url(@order)
    accept_confirm do
      click_on "Destroy This Order", match: :first
    end

    assert_text "Cannot destroy Order with associated Shipments."
  end

  test "should render po preview" do
    visit order_url(@order) + "/po"
    assert_text "brb101"
    assert_text "Warner Brothers"
  end

  test "should not throw errors when exporting" do
    visit order_url(@order)
    click_on "Export", match: :first
    within("div#order-export") do
      select "PDF", from: "File type"
      click_on "Export"
    end

    visit order_url(@order)
    click_on "Export", match: :first
    within("div#order-export") do
      select "CSV", from: "File type"
      assert_text "Export Format"
      click_on "Export"
    end

    visit order_url(@order)
    click_on "Export", match: :first
    within("div#order-export") do
      select "CSV", from: "File type"
      select "AutomationDirect", from: "Export Format"
      click_on "Export"
    end
  end

  test "should search and filter the index" do
    visit team_orders_url(@team)
    assert_text @order.po_number
    assert_text @one_part.po_number

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @order.po_number, :enter

    assert_no_text @one_part.po_number
    assert_text @order.job.name

    click_on "\u2716", match: :first

    assert_text @one_part.po_number
    assert_text @order.po_number

    click_on "Filters", match: :first

    fields = [ ["po_number", @order.po_number], ["job", @order.job.name], ["vendor", @order.vendor.name], ["created_by", @order.user.username] ]

    fields.each do |field|
      if ["job", "vendor", "created_by"].include? field[0]
        select field[1], from: field[0]
      else
        fill_in field[0], with: field[1]
      end
      click_on "Apply", match: :first

      assert_text @order.po_number
      field[0] == "vendor" ? (assert_text @one_part.po_number) : (assert_no_text @one_part.po_number)

      click_on "Reset", match: :first

      assert_text @order.po_number
      assert_text @one_part.po_number
    end

    fields = [["total_cost", [@order.total_cost - 1, @order.total_cost + 1]], ["order_date", [@order.order_date, @order.order_date]],
              ["parts_cost", [@order.parts_cost - 1, @order.parts_cost + 1]], ["tax_rate", [@order.tax_rate, @order.tax_rate]],
              ["tax_total", [@order.tax_total, @order.tax_total]], ["freight_cost", [@order.freight_cost - 1, @order.freight_cost + 1]]]

    fields.each do |field|
      min_suffix = field[0] == "order_date" ? "_start" : "_min"
      max_suffix = field[0] == "order_date" ? "_end" : "_max"
      fill_in field[0] + min_suffix, with: field[1][0]
      click_on "Apply", match: :first

      assert_text @order.po_number
      assert_no_text @one_part.po_number

      fill_in field[0] + max_suffix, with: field[1][1]
      click_on "Apply", match: :first

      assert_text @order.po_number
      assert_no_text @one_part.po_number

      fill_in field[0] + min_suffix, with: ""
      click_on "Apply", match: :first

      assert_text @order.po_number
      assert_text @one_part.po_number

      click_on "Reset", match: :first

      assert_text @order.po_number
      assert_text @one_part.po_number
    end

    assert_text @order.po_number
    assert_text @one_part.po_number
  end

  test "should sort index by column" do
    @jobless = orders(:jobless_order)
    visit team_orders_url(@team)

    assert_text @order.po_number
    assert_text @one_part.po_number

    sort_array = [
      ["PO Number", [@order.po_number, @one_part.po_number]], ["Total Cost", [@one_part.po_number, @order.po_number]], ["Job", [@one_part.po_number, @order.po_number]],
      ["Vendor", [@jobless.po_number, @order.po_number]], ["Created By", [@order.po_number, @one_part.po_number]], ["Parts Received", [@one_part.po_number, @order.po_number]]
    ]
    sort_array.each do |sort|
      header = find("th[data-action='click->table-order#sort']", text: sort[0], match: :first, wait: 10)
      sleep 1
      header.trigger("click")
      assert_text(/#{sort[1][0]}.*#{sort[1][1]}/m, wait: 10)
      sleep 1
      header.trigger("click")
      assert_text(/#{sort[1][1]}.*#{sort[1][0]}/m, wait: 10)
    end
  end
end
