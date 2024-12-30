# frozen_string_literal: true

require "test_helper"

class PartsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @part = parts(:big_red_button)
    @empty = parts(:empty)
    @component = components(:sd_button)
    @assembly = assemblies(:self_destruct_console)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
  end

  test "should get index" do
    get parts_url
    assert_response :success
  end

  test "should get new" do
    get new_part_url
    assert_response :success
  end

  test "should create part" do
    assert_difference("Part.count") do
      post parts_url, params: {
        part: {
          org_part_number: Part.next_org_part_number,
          manufacturer_id: @part.manufacturer.id,
          cost_per_unit: @part.cost_per_unit,
          description: @part.description,
          in_stock: @part.in_stock,
          notes: @part.notes,
          mfg_part_number: @part.mfg_part_number + "_2",
          optional_field_1: @part.optional_field_1,
          optional_field_2: @part.optional_field_2,
          organization_id: @team.organization_id,
          share_with: [teams(:submersibles).id, teams(:empty).id],
          team_id: @team.id
        }
      }
    end

    assert_redirected_to part_url(Part.last)
  end

  test "should show part" do
    @part.send(:generate_qr_code)
    get part_url(@part)
    assert_response :success
  end

  test "should get edit" do
    get edit_part_url(@part)
    assert_response :success
  end

  test "should update part" do
    patch part_url(@part),
      params: {
        part: {
          cost_per_unit: @part.cost_per_unit * 1.1,
          description: @part.description,
          in_stock: @part.in_stock,
          notes: @part.notes,
          mfg_part_number: @part.mfg_part_number,
          optional_field_1: @part.optional_field_1,
          optional_field_2: @part.optional_field_2,
          share_with: [teams(:submersibles).id, teams(:empty).id],
        }
      }
    assert_redirected_to part_url(@part)
  end

  test "should not destroy part with associated parts received or orders" do
    assert_no_difference("Part.count") do
      delete part_url(@part)
    end

    assert_redirected_to part_url(@part)
  end

  test "should destroy part with no associated parts received or orders" do
    assert_difference("Part.count", -1) do
      delete part_url(@empty)
    end

    assert_redirected_to parts_url
  end

  test "part cost change should change related assembly cost" do
    patch part_url(@part), params: { part: { cost_per_unit: 10.00 } }

    assert_equal(10.00, Part.find(@part.id).cost_per_unit)
    assert_equal(30.00, Assembly.find(@assembly.id).total_cost)
  end
end
