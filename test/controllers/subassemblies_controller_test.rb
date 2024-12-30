# frozen_string_literal: true

require "test_helper"

class SubassembliesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @apparatus_controls = subassemblies(:apparatus_controls)
    @control_switches = subassemblies(:control_switches)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:submersibles)
  end

  test "should get index" do
    get subassemblies_url
    assert_response :success
  end

  test "should get new" do
    get new_subassembly_url
    assert_response :success
  end

  test "should create subassembly" do
    assert_difference("Subassembly.count") do
      post subassemblies_url, params: { subassembly: { child_assembly_id: @control_switches.child_assembly_id,
                                                        parent_assembly_id: @apparatus_controls.parent_assembly_id,
                                                        quantity: 1,
                                                        organization_id: @team.organization_id,
                                                        team_id: @team.id } }
    end

    assert_redirected_to assembly_url(Subassembly.last.parent_assembly)
  end

  test "should add to already created subassembly quantity" do
    assert_no_difference("Subassembly.count") do
      post subassemblies_url, params: { subassembly: { child_assembly_id: @apparatus_controls.child_assembly_id,
                                                        parent_assembly_id: @apparatus_controls.parent_assembly_id,
                                                        quantity: 1,
                                                        organization_id: @team.organization_id,
                                                        team_id: @team.id } }
    end
    @apparatus_controls.reload
    assert_equal 2, @apparatus_controls.quantity

    assert_redirected_to assembly_url(@apparatus_controls.parent_assembly)
  end

  test "should show subassembly" do
    get subassembly_url(@apparatus_controls)
    assert_response :success
  end

  test "should get edit" do
    get edit_subassembly_url(@apparatus_controls)
    assert_response :success
  end

  test "should update subassembly" do
    patch subassembly_url(@apparatus_controls), params: { subassembly: { child_assembly_id: @apparatus_controls.child_assembly_id, parent_assembly_id: @apparatus_controls.parent_assembly_id } }
    assert_redirected_to assembly_url(@apparatus_controls.parent_assembly)
  end

  test "should destroy subassembly" do
    assert_difference("Subassembly.count", -1) do
      delete subassembly_url(@apparatus_controls)
    end

    assert_redirected_to assembly_url(@apparatus_controls.parent_assembly)
  end
end
