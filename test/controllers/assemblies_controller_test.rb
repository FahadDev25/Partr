# frozen_string_literal: true

require "test_helper"

class AssembliesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @assembly = assemblies(:self_destruct_console)
    @assembly_two = assemblies(:empty_assembly)
    @part_button = parts(:big_red_button)
    @part_glass = parts(:glass_pane)
    @part_claws = parts(:big_meaty_claw)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
  end

  test "should get index" do
    get assemblies_url
    assert_response :success
  end

  test "should get new" do
    get new_assembly_url
    assert_response :success
  end

  test "should create assembly" do
    assert_difference("Assembly.count") do
      post assemblies_url, params: {
        assembly: {
          name: "#{@assembly.name}test",
          total_cost: @assembly.total_cost,
          organization_id: @team.organization_id,
          team_id: @team.id,
          share_with: [teams(:submersibles).id, teams(:empty).id]
        }
      }
    end

    assert_redirected_to assembly_url(Assembly.last)
  end

  test "should show assembly" do
    get assembly_url(@assembly)
    assert_response :success
  end

  test "should get edit" do
    get edit_assembly_url(@assembly)
    assert_response :success
  end

  test "should update assembly" do
    patch assembly_url(@assembly), params: {
      assembly: {
        name: @assembly.name,
        total_cost: @assembly.total_cost,
        share_with: [teams(:submersibles).id, teams(:empty).id]
      }
    }
    assert_redirected_to assembly_url(@assembly)
  end

  test "should destroy assembly with no associated jobs or shipments" do
    assert_difference("Assembly.count", -1) do
      delete assembly_url(@assembly_two)
    end

    assert_redirected_to assemblies_url
  end

  test "should not destroy assembly with associated jobs or shipments" do
    assert_no_difference("Assembly.count") do
      delete assembly_url(@assembly)
    end

    assert_redirected_to assembly_url(@assembly)
  end

  test "add multiple components" do
    @assembly_two.add_part(@part_button, 1, @team.organization).save!
    @assembly_two.add_part(@part_glass, 1, @team.organization).save!

    @assembly_two.reload
    assert_equal(2, @assembly_two.components.count)
    assert_equal @assembly_two.total_cost, @part_button.cost_per_unit + @part_glass.cost_per_unit
  end

  test "add the same component multiple times" do
    @assembly_two.add_part(@part_claws, 1, @team.organization).save!
    @assembly_two.add_part(@part_claws, 1, @team.organization).save!

    assert_equal(1, @assembly_two.components.count)
    assert_equal(2, @assembly_two.components[0].quantity)
    assert_equal @assembly_two.total_cost, @part_claws.cost_per_unit * 2
  end
end
