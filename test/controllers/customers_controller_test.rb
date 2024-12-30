# frozen_string_literal: true

require "test_helper"

class CustomersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @customer = customers(:wile)
    @customer2 = customers(:unassociated)
    @user = users(:admin)
    sign_in @user
    @user.current_team = teams(:trapsmiths)
  end

  test "should get index" do
    get customers_url
    assert_response :success
  end

  test "should get new" do
    get new_customer_url
    assert_response :success
  end

  test "should create customer" do
    assert_difference("Customer.count") do
      post customers_url, params: { customer: { name: "Test", team_id: @user.current_team.id } }
    end

    assert_redirected_to customer_url(Customer.last)
  end

  test "should show customer" do
    get customer_url(@customer)
    assert_response :success
  end

  test "should get edit" do
    get edit_customer_url(@customer)
    assert_response :success
  end

  test "should update customer" do
    patch customer_url(@customer), params: { customer: { name: "New name" } }
    assert_redirected_to customer_url(@customer)
  end

  test "should destroy customer with no associated jobs" do
    assert_difference("Customer.count", -1) do
      delete customer_url(@customer2)
    end

    assert_redirected_to customers_url
  end

  test "should not destroy customer with associated jobs" do
    assert_no_difference("Customer.count") do
      delete customer_url(@customer)
    end

    assert_redirected_to customer_url(@customer)
  end
end
