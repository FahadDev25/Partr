# frozen_string_literal: true

require "application_system_test_case"

class PartsReceivedTest < ApplicationSystemTestCase
  setup do
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "cross team search" do
    job = jobs(:trap)
    order = orders(:button_order)
    shipment = shipments(:button_shipment)

    visit home_team_url(@user.current_team)

    fill_in "Search", with: job.job_number
    click_on "Go", match: :first
    assert_selector "h1", text: "Results for '#{job.job_number}'"
    assert_selector "strong", text: "Jobs:"
    assert_selector "a", text: job.name
    assert_selector "strong", text: "Orders:"
    assert_selector "a", text: order.po_number
    assert_selector "strong", text: "Shipments:"
    assert_selector "a", text: shipment.shipping_number

    fill_in "Search", with: order.po_number
    click_on "Go", match: :first
    assert_selector "h1", text: "Results for '#{order.po_number}'"
    assert_no_selector "strong", text: "Jobs:"
    assert_selector "strong", text: "Orders:"
    assert_selector "a", text: order.po_number
    assert_selector "strong", text: "Shipments:"
    assert_selector "a", text: shipment.shipping_number

    fill_in "Search", with: shipment.shipping_number
    click_on "Go", match: :first
    assert_selector "h1", text: "Results for '#{shipment.shipping_number}'"
    assert_no_selector "strong", text: "Jobs:"
    assert_no_selector "strong", text: "Orders:"
    assert_selector "strong", text: "Shipments:"
    assert_selector "a", text: shipment.shipping_number
  end
end
