# frozen_string_literal: true

require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @order = orders(:button_order)
    @empty_order = orders(:empty_order)
    @jobless_order = orders(:jobless_order)
    @part_button = parts(:big_red_button)
    @part_pane = parts(:glass_pane)
    @part_claw = parts(:big_meaty_claw)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
  end

  test "should get index" do
    get team_orders_url(@team)
    assert_response :success
  end

  test "should get new" do
    get new_team_order_url(@team)
    assert_response :success
  end

  test "should create order" do
    assert_difference("Order.count") do
      post team_orders_url(@team),
        params: {
          order: {
            po_prefix: "KRJO",
            job_id: @order.job_id,
            order_date: @order.order_date,
            parts_cost: @order.parts_cost,
            vendor_id: @order.vendor_id,
            team_id: @team.id,
            organization_id: @team.organization_id,
            include_job_name: true,
            include_job_number: true
          }
        }
    end

    assert_redirected_to order_url(Order.last)
  end

  test "should create order without job" do
    assert_difference("Order.count") do
      post team_orders_url(@team),
        params: {
          order: {
            po_prefix: "KRJO",
            job_id: nil,
            order_date: @jobless_order.order_date,
            parts_cost: @jobless_order.parts_cost,
            vendor_id: @jobless_order.vendor_id,
            team_id: @team.id,
            organization_id: @team.organization_id,
            quote_number: @order.quote_number,
            fob: @order.fob,
            needs_reimbursement: true,
            ship_to_attributes: {
              address_1: @order.ship_to&.address_1,
              address_2: @order.ship_to&.address_2,
              city: @order.ship_to&.city,
              state: @order.ship_to&.state,
              zip_code: @order.ship_to&.zip_code
            },
            billing_address_attributes: {
              address_1: @order.billing_address&.address_1,
              address_2: @order.billing_address&.address_2,
              city: @order.billing_address&.city,
              state: @order.billing_address&.state,
              zip_code: @order.billing_address&.zip_code
            }
          }
        }
      assert_enqueued_emails 1
    end

    assert_redirected_to order_url(Order.last)
  end

  test "should add components to order without job" do
    @jobless_order.add_part(@part_button, nil, [], 1, 0.0, @team.organization).save!
    @jobless_order.add_part(@part_pane, nil, [], 1, 0.0, @team.organization).save!
    @jobless_order.update_cost

    assert_equal(2, @jobless_order.line_items.count)
    assert_equal @jobless_order.parts_cost, @part_button.cost_per_unit + @part_pane.cost_per_unit
  end

  test "should show order" do
    get order_url(@order)
    assert_response :success
  end

  test "should get edit" do
    get edit_order_url(@order)
    assert_response :success
  end

  test "should update order" do
    patch order_url(@order),
      params: {
        order: {
          job_id: @order.job_id, order_date: @order.order_date,
          parts_cost: @order.parts_cost,
          vendor_id: @order.vendor_id,
          team_id: @team.id, organization_id: @team.organization_id,
          include_job_name: true,
          include_job_number: true,
          quote_number: @order.quote_number,
          fob: @order.fob,
          needs_reimbursement: true,
          ship_to_attributes: {
            address_1: @order.ship_to&.address_1,
            address_2: @order.ship_to&.address_2,
            city: @order.ship_to&.city,
            state: @order.ship_to&.state,
            zip_code: @order.ship_to&.zip_code
          },
          billing_address_attributes: {
            address_1: @order.billing_address&.address_1,
            address_2: @order.billing_address&.address_2,
            city: @order.billing_address&.city,
            state: @order.billing_address&.state,
            zip_code: @order.billing_address&.zip_code
          }
        }
      }
    assert_redirected_to order_url(@order)
  end

  test "should destroy order with no associated shipments" do
    assert_difference("Order.count", -1) do
      delete order_url(@empty_order)
    end

    assert_redirected_to team_orders_url(@team)
  end

  test "should not destroy order with associated shipments" do
    assert_no_difference("Order.count") do
      delete order_url(@order)
    end

    assert_redirected_to order_url(@order)
  end

  test "add multiple components" do
    @empty_order.add_part(@part_button, nil, [], 1, 0.0, @team.organization).save!
    @empty_order.add_part(@part_pane, nil, [], 1, 0.0, @team.organization).save!
    @empty_order.update_cost

    assert_equal(2, @empty_order.line_items.count)
    assert_equal @empty_order.parts_cost, @part_button.cost_per_unit + @part_pane.cost_per_unit
  end

  test "add the same component multiple times" do
    @empty_order.add_part(@part_claw, nil, [], 1, 0.0, @team.organization).save!
    @empty_order.add_part(@part_claw, nil, [], 1, 0.0, @team.organization).save!
    @empty_order.update_cost

    assert_equal(1, @empty_order.line_items.count)
    assert_equal(2, @empty_order.line_items[0].quantity)
    assert_equal @empty_order.parts_cost, @part_claw.cost_per_unit * 2
  end
end
