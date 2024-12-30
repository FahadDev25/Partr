# frozen_string_literal: true

require "test_helper"

class PartsReceivedControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @part_received = parts_received(:one)
    @jobless_received = parts_received(:jobless)
    @jobless_part = parts(:big_meaty_claw)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
  end

  test "should get index" do
    get parts_received_url
    assert_response :success
  end

  test "should get new" do
    get new_part_received_url, params: { shipment_id: @part_received.shipment_id }
    assert_response :success
  end

  test "should create part_received" do
    assert_difference("PartReceived.count") do
      post parts_received_url,
           params: { part_received: { assembly_id: @part_received.assembly_id, part_id: @part_received.part_id,
                                      quantity: @part_received.quantity, shipment_id: @part_received.shipment_id } }
    end

    assert_redirected_to shipment_url(PartReceived.last.shipment)
  end

  test "should add parts received to shipment without job or order" do
    assert_difference("PartReceived.count") do
      post parts_received_url,
           params: { part_received: { assembly_id: nil, part_id: @jobless_received.part_id,
                                      quantity: @jobless_received.quantity, shipment_id: @jobless_received.shipment_id } }
    end

    assert_equal 4, @jobless_received.part.in_stock

    assert_redirected_to shipment_url(PartReceived.last.shipment)
  end

  test "should show part_received" do
    get part_received_url(@part_received)
    assert_response :success
  end

  test "should get edit" do
    get edit_part_received_url(@part_received)
    assert_response :success
  end

  test "should update part_received" do
    patch part_received_url(@part_received),
          params: { part_received: { assembly_id: @part_received.assembly_id, part_id: @part_received.part_id,
                                     quantity: @part_received.quantity, shipment_id: @part_received.shipment_id },
                                     previous_request: shipment_url(@part_received.shipment) }
    assert_redirected_to shipment_url(@part_received.shipment)
  end

  test "should destroy part_received" do
    assert_difference("PartReceived.count", -1) do
      delete part_received_url(@part_received)
    end

    assert_redirected_to shipment_url(@part_received.shipment)
  end
end
