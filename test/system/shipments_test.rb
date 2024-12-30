# frozen_string_literal: true

require "application_system_test_case"

class ShipmentsTest < ApplicationSystemTestCase
  setup do
    @shipment = shipments(:button_shipment)
    @shipment.packing_slips.attach(io: File.open("test/fixtures/files/slip1.png"), filename: "slip1.png", content_type: "image/png")
    @jobless = shipments(:jobless)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit team_shipments_url(@team)
    assert_selector "h1", text: "Shipments"
  end

  test "should create shipment" do
    visit team_shipments_url(@team)
    click_on "New Shipment"

    assert_difference "ActionMailer::Base.deliveries.size" do
      fill_in "Date received", with: @shipment.date_received
      fill_in "From", with: @shipment.from
      select @shipment.job.name, from: "Job"
      fill_in "Notes", with: @shipment.notes
      select @shipment.order.name, from: "Order"
      fill_in "Shipping number", with: @shipment.shipping_number
      attach_file "Packing Slip(s)", (Rails.root + "test/fixtures/files/slip1.png")
      click_on "Create Shipment"

      assert_text "Shipment was successfully created"
    end
    click_on "Back"

    mail = ActionMailer::Base.deliveries.last
    assert_equal ["admin@bio-next.net"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match (/#{@shipment.from}/), mail.text_part.encoded
    assert_match (/#{@shipment.shipping_number}/), mail.text_part.encoded
    assert_match (/#{@shipment.from}/), mail.html_part.encoded
    assert_match (/#{@shipment.shipping_number}/), mail.html_part.encoded
  end

  test "should create shipment from order" do
    visit team_orders_url(@team)
    click_on "Create Shipment", match: :first
    fill_in "Date received", with: @shipment.date_received
    fill_in "From", with: @shipment.from
    fill_in "Shipping number", with: @shipment.shipping_number
    within("div#modal-content") { click_on "Create Shipment" }

    assert_text "Shipment was successfully created"

    visit order_url(orders(:button_order))
    click_on "Create Shipment", match: :first
    fill_in "Date received", with: @shipment.date_received
    fill_in "From", with: @shipment.from
    fill_in "Shipping number", with: @shipment.shipping_number
    within("div#modal-content") { click_on "Create Shipment" }

    assert_text "Shipment was successfully created"
  end

  test "should update Shipment" do
    visit shipment_url(@shipment)
    click_on "Edit This Shipment", match: :first

    fill_in "Date received", with: @shipment.date_received
    fill_in "From", with: @shipment.from
    select @shipment.job.name, from: "Job"
    fill_in "Notes", with: @shipment.notes
    select @shipment.order.name, from: "Order"
    fill_in "Shipping number", with: @shipment.shipping_number
    attach_file "Packing Slip(s)", (Rails.root + "test/fixtures/files/slip1.png")
    click_on "Update Shipment"

    assert_text "Shipment was successfully updated"
    click_on "Back"
  end

  test "should destroy Shipment" do
    visit shipment_url(@shipment)
    accept_confirm do
      click_on "Destroy This Shipment", match: :first
    end

    assert_text "Shipment was successfully destroyed"
  end

  test "should remove packing slip" do
    visit shipment_url(@shipment)
    click_on "Edit This Shipment", match: :first

    assert_text "Remove"

    within("turbo-frame#modal") do
      click_on "Remove", match: :first
      assert_no_text "Remove"
    end

    @shipment.reload
    assert_predicate @shipment.packing_slips, :empty?
  end

  test "should search and filter the index" do
    visit team_shipments_url(@team)
    assert_text @shipment.shipping_number

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @shipment.shipping_number, :enter

    assert_no_text @jobless.shipping_number
    assert_text @shipment.order.po_number

    click_on "\u2716", match: :first

    assert_text @jobless.shipping_number
    assert_text @shipment.shipping_number

    click_on "Filters", match: :first

    fields = [ ["shipping_number", @shipment.shipping_number], ["job", @shipment.job.name], ["order_id", @shipment.order.name], ["from", @shipment.from],
               ["notes", @shipment.notes] ]

    fields.each do |field|
      sleep 0.1
      if ["job", "order_id"].include? field[0]
        select field[1], from: field[0]
      else
        fill_in field[0], with: field[1]
      end
      click_on "Apply", match: :first

      assert_text @shipment.shipping_number
      assert_no_text @jobless.shipping_number

      click_on "Reset", match: :first

      assert_text @shipment.shipping_number
      assert_text @jobless.shipping_number
    end

    fields = [["date_received", [@shipment.date_received, @shipment.date_received]]]
    fields.each do |field|
      fill_in field[0] + "_start", with: field[1][0]
      click_on "Apply", match: :first

      assert_text @shipment.shipping_number
      assert_no_text @jobless.shipping_number

      fill_in field[0] + "_end", with: field[1][1]
      click_on "Apply", match: :first

      assert_text @shipment.shipping_number
      assert_no_text @jobless.shipping_number

      fill_in field[0] + "_start", with: ""
      click_on "Apply", match: :first

      assert_text @shipment.shipping_number
      assert_text @jobless.shipping_number

      click_on "Reset", match: :first

      assert_text @shipment.shipping_number
      assert_text @jobless.shipping_number
    end

    assert_text @shipment.shipping_number
    assert_text @jobless.shipping_number
  end

  test "should sort index by column" do
    visit team_shipments_url(@team)

    assert_text @shipment.shipping_number
    assert_text @jobless.shipping_number

    sort_array = [["Shipping Number", [@shipment.shipping_number, @jobless.shipping_number]], ["Job", [@shipment.shipping_number, @jobless.shipping_number]],
                  ["Order", [@shipment.shipping_number, @jobless.shipping_number]], ["From", [@shipment.shipping_number, @jobless.shipping_number]],
                  ["Notes", [@jobless.shipping_number, @shipment.shipping_number]] ]
    sort_array.each do |sort|
      header = find("th[data-action='click->table-order#sort']", text: sort[0], match: :first, wait: 5)
      header.click
      assert_text(/#{sort[1][0]}.*#{sort[1][1]}/m, wait: 5)
      header.click
      assert_text(/#{sort[1][1]}.*#{sort[1][0]}/m, wait: 5)
    end
  end
end
