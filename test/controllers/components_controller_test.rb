# frozen_string_literal: true

require "test_helper"

class ComponentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @assembly = assemblies(:self_destruct_console)
    @component = components(:sd_button)
    @component2 = components(:claws)
    @user = users(:admin)
    sign_in @user
    @user.current_team = teams(:trapsmiths)
  end

  test "should get index" do
    get components_url
    assert_response :success
  end

  test "should get new" do
    get new_component_url(@assembly), params: { assembly_id: @component.assembly_id }
    assert_response :success
  end

  test "should create component" do
    assert_difference("Component.count") do
      post components_url,
           params: { component: { assembly_id: @component.assembly_id, part_id: @component2.part_id,
                                  quantity: @component.quantity } }
    end

    assert_redirected_to assembly_url(Component.last.assembly)
  end

  test "should show component" do
    get component_url(@component)
    assert_response :success
  end

  test "should get edit" do
    get edit_component_url(@component)
    assert_response :success
  end

  test "should update component" do
    patch component_url(@component),
          params: { component: { assembly_id: @component.assembly_id, part_id: @component.part_id,
                                 quantity: @component.quantity } }
    assert_redirected_to assembly_url(@component.assembly)
  end

  test "should destroy component" do
    assert_difference("Component.count", -1) do
      delete component_url(@component)
    end
    assert_redirected_to assembly_url(@assembly)
  end
end
