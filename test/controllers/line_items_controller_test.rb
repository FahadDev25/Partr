# frozen_string_literal: true

require "test_helper"

class LineItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @line_item = line_items(:one_button)
    @line_item_two = line_items(:two_claws)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
  end

  test "should get new" do
    get new_line_item_url, params: { order_id: @line_item.order_id }
    assert_response :success
  end

  test "should create line_item" do
    assert_difference("LineItem.count") do
      post line_items_url,
        params: {
          line_item: {
            order_id: @line_item.order_id,
            part_id: @line_item_two.part_id,
            assembly_id: "[#{@line_item.assembly_id},[]]",
            quantity: @line_item.quantity,
            discount: 0.05,
            expected_delivery: Date.today,
            status_location: @line_item.status_location,
            om_warranty: @line_item.om_warranty,
            notes: @line_item.notes
          }
        }
    end

    assert_redirected_to order_url(LineItem.last.order)
  end

  test "should get edit" do
    get edit_line_item_url(@line_item)
    assert_response :success
  end

  test "should update line_item" do
    patch line_item_url(@line_item),
          params: {
            line_item: {
              order_id: @line_item.order_id,
              part_id: @line_item_two.part_id,
              quantity: @line_item.quantity,
              expected_delivery: Date.today,
              status_location: @line_item.status_location,
              om_warranty: @line_item.om_warranty,
              notes: @line_item.notes
            }
          }
    assert_redirected_to order_url(@line_item.order)
  end


  test "should not destroy line_item with associated parts received" do
    assert_no_difference("LineItem.count") do
      delete line_item_url(@line_item)
    end

    assert_redirected_to order_url(@line_item.order)
  end

  test "should destroy line_item" do
    assert_difference("LineItem.count", -1) do
      delete line_item_url(line_items(:sub_levers))
    end

    assert_redirected_to order_url(line_items(:sub_levers).order)
  end
end
