# frozen_string_literal: true

require "application_system_test_case"

class SubassembliesTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  setup do
    @apparatus_controls = subassemblies(:apparatus_controls)
    @control_switches = subassemblies(:control_switches)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:submersibles)
    @user.save!
  end

  test "visiting the index" do
    visit subassemblies_url
    assert_selector "h1", text: "Subassemblies"
  end

  test "should create subassembly" do
    visit assembly_url(@apparatus_controls.parent_assembly)
    click_on "Add Subassembly"

    within("select#subassembly_child_assembly_id") do
      assert_no_text @apparatus_controls.parent_assembly.name
    end
    select @control_switches.child_assembly.name, from: "Child Assembly"
    fill_in "Quantity", with: @apparatus_controls.quantity
    click_on "Create Subassembly"
  end

  test "should update Subassembly" do
    visit assembly_url(@apparatus_controls.parent_assembly)
    within("tr#subassembly_#{@apparatus_controls.id}") do
      click_on "Edit", match: :first
    end

    within("select#subassembly_child_assembly_id") do
      assert_no_text @apparatus_controls.parent_assembly.name
    end
    select @apparatus_controls.child_assembly.name, from: "Child Assembly"
    fill_in "Quantity", with: @apparatus_controls.quantity
    click_on "Update Subassembly"
  end

  test "should destroy Subassembly" do
    visit assembly_url(@apparatus_controls.parent_assembly)
    within("tr#subassembly_#{@apparatus_controls.id}") do
      click_on "Remove", match: :first
    end

    assert_text "Subassembly was successfully destroyed"
  end
end
