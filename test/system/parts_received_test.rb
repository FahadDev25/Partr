# frozen_string_literal: true

require "application_system_test_case"

class PartsReceivedTest < ApplicationSystemTestCase
  setup do
    @part_received = parts_received(:one)
    @more_pane = additional_parts(:more_pane)
    @aok = assemblies(:aok)
    @no_claws = parts(:big_meaty_claw)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit parts_received_url
    assert_selector "h1", text: "Parts Received"
  end

  test "should create part received for additional_part" do
    line_item = line_items(:no_received_additional_part)
    visit shipment_url(shipments(:no_received_shipment))
    click_on "Add Part Received"

    sleep(0.5)

    tom_select line_item.part.label, from: "Line Item"
    fill_in "Quantity", with: line_item.quantity
    click_on "Create Part received"

    assert_text "Part received was successfully created"
    click_on "Back"
  end

  test "should create part received from line item list" do
    line_item = line_items(:no_received_additional_part)
    visit order_url(orders(:no_received_order))

    within("tr#line_item_#{line_item.id}") { click_on "+" }

    tom_select line_item.part.label, from: "Line Item"
    fill_in "Quantity", with: line_item.quantity
    click_on "Create Part received"

    within("tr#line_item_#{line_item.id}") { assert_text "#{line_item.quantity.to_i}/#{line_item.quantity.to_i}" }

    assert_text "Part received was successfully created"
    click_on "Back"
  end

  test "should create part received for unit" do
    line_item = line_items(:no_received_unit)
    visit shipment_url(shipments(:no_received_shipment))
    click_on "Add Part Received"

    tom_select line_item.part_and_assembly, from: "Line Item"
    fill_in "Quantity", with: line_item.quantity
    click_on "Create Part received"

    assert_text "Part received was successfully created"
    click_on "Back"
  end

  test "should create part received for part/unit line item in manual order" do
    line_item = line_items(:sub_levers)
    visit home_team_url(teams(:submersibles))
    visit shipment_url(shipments(:claws_shipment))
    click_on "Add Part Received"

    tom_select line_item.part_and_assembly, from: "Line Item"
    fill_in "Quantity", with: line_item.quantity
    click_on "Create Part received"

    assert_text "Part received was successfully created"

    line_item.reload
    visit order_url(line_item.order)
    assert_text "#{(line_item.quantity_received).to_s.sub(/\.0+$/, '')}/#{line_item.quantity.to_s.sub(/\.0+$/, '')}"
    click_on "Back"
  end

  test "should create part received for manual line item in manual order" do
    line_item = line_items(:claw_installation)
    visit home_team_url(teams(:submersibles))
    visit shipment_url(shipments(:claws_shipment))
    click_on "Add Part Received"

    assert_text line_item.description
    tom_select line_item.description, from: "Line Item"
    fill_in "Quantity", with: line_item.quantity
    click_on "Create Part received"

    assert_text "Part received was successfully created"

    visit order_url(line_item.order)
    assert_text "#{line_item.quantity.to_s.sub(/\.0+$/, '')}/#{line_item.quantity.to_s.sub(/\.0+$/, '')}"
    click_on "Back"
  end

  test "should update Part received" do
    visit shipment_url(@part_received.shipment_id)
    click_on "Edit", match: :first

    select @part_received.shipment.label, from: "Shipment"
    tom_select "#{@part_received.part.label} (#{@part_received.assembly.name})", from: "Line Item"
    fill_in "Quantity", with: @part_received.quantity
    click_on "Update Part received"

    assert_text "Part received was successfully updated"
    click_on "Back"
  end

  test "should destroy Part received" do
    visit shipment_url(@part_received.shipment_id)
    click_on "Remove", match: :first

    assert_text "Part received was successfully destroyed"
  end

  test "should create part received for unit subassembly" do
    line_items(:claw_installation).delete
    @claws_shipment = shipments(:claws_shipment)
    @lever = parts(:lever)
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!

    visit shipment_url(@claws_shipment)
    click_on "Add Part Received"

    tom_select "#{@lever.label}", from: "Line Item"

    fill_in "Quantity", with: 1
    click_on "Create Part received"

    assert_text "Part received was successfully created"
  end

  test "should create part received for unit subassembly in manual order" do
    @claws_shipment = shipments(:claws_shipment)
    @lever_item = line_items(:sub_levers)
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!

    visit shipment_url(@claws_shipment)
    click_on "Add Part Received"

    assert_text @lever_item.part_and_assembly
    assert_no_text @part_received.part.label
    tom_select @lever_item.part_and_assembly, from: "Line Item"

    fill_in "Quantity", with: @lever_item.quantity
    click_on "Create Part received"

    assert_text "Part received was successfully created"
  end
end
