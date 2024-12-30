# frozen_string_literal: true

require "test_helper"

class OtherPartNumbersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @other_part_number = other_part_numbers(:red_button_meco)
    @red_primary = other_part_numbers(:red_button_primary)
    @two = other_part_numbers(:two)
    @part = parts(:big_red_button)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "should get index" do
    get part_other_part_numbers_url(@part)
    assert_response :success
  end

  test "should get new" do
    get new_part_other_part_number_url(@part)
    assert_response :success
  end

  test "should create other_part_number" do
    assert_difference("OtherPartNumber.count") do
      post part_other_part_numbers_url(@part),
        params: {
          other_part_number: {
            company_id: @two.company_id,
            organization_id: @two.organization_id,
            cost_per_unit: 2.50,
            part_id: @two.part_id,
            part_number: @two.part_number,
            company_type: @two.company_type
          }
        }
    end

    assert_redirected_to part_url(OtherPartNumber.last.part)
    assert_equal 1, PriceChange.where(other_part_number_id: OtherPartNumber.last.id).count
  end

  test "should show other_part_number" do
    get other_part_number_url(@other_part_number)
    assert_response :success
  end

  test "should get edit" do
    get edit_other_part_number_url(@other_part_number)
    assert_response :success
  end

  test "should update other_part_number" do
    assert_difference("PriceChange.count") do
      patch other_part_number_url(@red_primary),
        params: {
          other_part_number: {
            company_id: @red_primary.company_id,
            organization_id: @red_primary.organization_id,
            cost_per_unit: @red_primary.cost_per_unit + 1,
            part_id: @red_primary.part_id,
            part_number: @red_primary.part_number,
            company_type: @red_primary.company_type
          }
        }
    end
    @red_primary.reload
    assert_equal Date.today, @red_primary.last_price_update
    assert_equal @red_primary.cost_per_unit, @red_primary.part.cost_per_unit
    assert_redirected_to part_url(@red_primary.part)
  end

  test "should destroy other_part_number" do
    assert_difference("OtherPartNumber.count", -1) do
      delete other_part_number_url(@other_part_number)
    end

    assert_redirected_to part_url(@part)
  end
end
