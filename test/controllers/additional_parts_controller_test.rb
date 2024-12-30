# frozen_string_literal: true

require "test_helper"

class AdditionalPartsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @additional_part = additional_parts(:extra_claws)
    @button = parts(:big_red_button)
    @user = users(:admin)
    sign_in @user
    @user.current_team = teams(:trapsmiths)
  end

  test "should get index" do
    get additional_parts_url
    assert_response :success
  end

  test "should get new" do
    get new_additional_part_url, params: { job_id: @additional_part.job_id }
    assert_response :success
  end

  test "should create additional_part" do
    assert_difference("AdditionalPart.count") do
      post additional_parts_url, params: { additional_part: { job_id: @additional_part.job_id, part_id: @button.id, quantity: @additional_part.quantity } }
    end

    assert_redirected_to job_url(@additional_part.job)
  end

  test "should show additional_part" do
    get additional_part_url(@additional_part)
    assert_response :success
  end

  test "should get edit" do
    get edit_additional_part_url(@additional_part)
    assert_response :success
  end

  test "should update additional_part" do
    patch additional_part_url(@additional_part), params: { additional_part: { job_id: @additional_part.job_id, part_id: @additional_part.part_id, quantity: @additional_part.quantity } }
    assert_redirected_to job_url(@additional_part.job)
  end

  test "should destroy additional_part" do
    assert_difference("AdditionalPart.count", -1) do
      delete additional_part_url(@additional_part)
    end

    assert_redirected_to job_url(@additional_part.job)
  end
end
