# frozen_string_literal: true

require "application_system_test_case"

class LineItemsTest < ApplicationSystemTestCase
  setup do
    attachments(:one).file.attach(io: File.open("test/fixtures/files/slip1.png"), filename: "slip1.png", content_type: "image/png")
    @button = line_items(:one_button)
    @pane = parts(:glass_pane)
    @claw = parts(:big_meaty_claw)
    @aok = assemblies(:aok)
    @one_part = orders(:one_part)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "should create line item for part from unit" do
    visit order_url(@button.order)
    click_on "Add Line Item"

    assert_text @pane.label
    select @pane.label, from: "Part"
    select @button.assembly.name, from: "Assembly"
    fill_in "Quantity", with: "1"
    fill_in "Expected delivery", with: Date.today
    fill_in "Status / Location", with: @button.status_location
    fill_in "O&M Warranty", with: @button.om_warranty
    fill_in "Notes", with: @button.notes
    click_on "Create Line item"

    @button.order.reload

    assert_equal 23.50, @button.order.parts_cost
    assert_equal 1.175, @button.order.tax_total

    assert_text "Line item was successfully created"

    visit job_url(@button.order.job)
    assert_text "1/3"

    click_on "Back"
  end

  test "should create line item for part from unit for jobless order" do
    jobless = orders(:jobless_order)
    visit order_url(jobless)
    click_on "Add Line Item"

    assert_text @claw.label
    select @claw.label, from: "Part"
    select @aok.name, from: "Assembly"
    fill_in "Quantity", with: "1"
    click_on "Create Line item"

    jobless.reload

    assert_equal 5.00, jobless.parts_cost
    assert_equal 0.25, jobless.tax_total

    assert_text "Line item was successfully created"

    click_on "Back"
  end

  test "should mark line items received for order with mark_line_items_received: true" do
    visit order_url(orders(:in_store_order))
    click_on "Add Line Item"

    assert_text @pane.label
    select @pane.label, from: "Part"
    select @button.assembly.name, from: "Assembly"
    fill_in "Quantity", with: "10"
    click_on "Create Line item"

    assert_text "Line item was successfully created"

    assert_text "10/10"

    click_on "Back"
  end

  test "should create line item for additional part" do
    visit order_url(@one_part)
    click_on "Add Line Item"

    select @button.part.label, from: "Part"
    fill_in "Quantity", with: "1"
    click_on "Create Line item"

    assert_text "Line item was successfully created"

    visit job_url(@one_part.job)
    assert_text "1/1"

    click_on "Back"
  end

  test "should create manual line item" do
    visit home_team_url(teams(:submersibles))
    visit order_url(orders(:claws_order))
    click_on "Add Line Item"

    fill_in "Description", with: "Test Descripion"
    fill_in "Cost per Unit", with: "3.50"
    fill_in "Quantity", with: "1"
    click_on "Create Line item"

    assert_text "Line item was successfully created"

    click_on "Back"
  end

  test "should update Line item" do
    visit order_url(@button.order)
    click_on "Edit", match: :first

    select @button.order.name, from: "Order"
    select @button.part.label, from: "Part"
    fill_in "Quantity", with: @button.quantity
    fill_in "Expected delivery", with: Date.today
    fill_in "Status / Location", with: @button.status_location
    fill_in "O&M Warranty", with: @button.om_warranty
    fill_in "Notes", with: @button.notes
    click_on "Update Line item"

    assert_text "Line item was successfully updated"
    click_on "Back"
  end

  test "should not destroy Line item with parts received" do
    visit order_url(@button.order)
    click_on "Remove", match: :first

    assert_text "Cannot destroy line item with associated parts received"
  end

  test "should destroy Line item" do
    visit order_url(line_items(:sub_levers).order)
    within("tr#line_item_#{line_items(:sub_levers).id}") { click_on "Remove" }

    assert_text "Line item was successfully destroyed"
  end

  test "should add line item from subassembly" do
    @claws_order = orders(:claws_order)
    @lever = parts(:lever)
    @user.current_team = @team = teams(:submersibles)
    @user.save!

    visit order_url(@claws_order)

    click_on "Add Line Item"

    uncheck "line_item_manual"
    select @lever.label, from: "Part"
    fill_in "Quantity", with: "1"
    click_on "Create Line item"

    assert_text "Line item was successfully created"
  end
end
