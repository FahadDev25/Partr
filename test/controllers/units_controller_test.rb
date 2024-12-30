# frozen_string_literal: true

require "test_helper"

class UnitsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @unit = units(:failsafe)
    @unit2 = units(:vault_breaker)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
  end

  test "should get index" do
    get units_url
    assert_response :success
  end

  test "should get new" do
    get new_unit_url, params: { job_id: @unit.job_id }
    assert_response :success
  end

  test "should create unit" do
    assert_difference("Unit.count") do
      post units_url, params: { unit: { job_id: @unit.job_id, assembly_id: @unit2.assembly.id, quantity: @unit.quantity } }
    end

    assert_redirected_to job_url(@unit.job)
  end

  test "should show unit" do
    get unit_url(@unit)
    assert_response :success
  end

  test "should get edit" do
    get edit_unit_url(@unit)
    assert_response :success
  end

  test "should update unit" do
    patch unit_url(@unit),
          params: { unit: { job_id: @unit.job_id, assembly_id: @unit.assembly_id, quantity: @unit.quantity } }
    assert_redirected_to job_url(@unit.job)
  end

  test "should destroy unit" do
    assert_difference("Unit.count", -1) do
      delete unit_url(@unit)
    end

    assert_redirected_to job_url(@unit.job)
  end
end
