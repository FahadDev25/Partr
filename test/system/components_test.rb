# frozen_string_literal: true

require "application_system_test_case"

class ComponentsTest < ApplicationSystemTestCase
  setup do
    @assembly = assemblies(:self_destruct_console)
    @component = components(:sd_button)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit assembly_url(@assembly)
    assert_selector "h3", text: "Component List"
  end

  test "should create component" do
    visit assembly_url(@component.assembly)
    click_on "Add Component"

    select "go button", from: "Assembly"
    select "ACME brb101", from: "Part"
    fill_in "Quantity", with: @component.quantity
    click_on "Create Component"

    assert_text @component.part.label
  end

  test "should update Component" do
    visit assembly_url(@assembly)
    click_on "Edit", match: :first

    select "go button", from: "Assembly"
    select "ACME brb101", from: "Part"
    fill_in "Quantity", with: @component.quantity + 1
    click_on "Update Component"

    assert_text (@component.quantity + 1).to_s.sub(/\.0+$/, "")
    click_on "Back"
  end

  test "should destroy Component" do
    visit assembly_url(@assembly)
    click_on "Remove", match: :first

    assert_no_text @component.part.label
  end

  test "should search and filter assembly component list" do
    visit assembly_url(@assembly)
    assert_text "brb101"

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.send_keys @component.part.mfg_part_number, :enter

    assert_no_text "gbc101"
    assert_text "brb101"

    assert_text "brb101"

    click_on "Filters", match: :first

    fields = [ ["mfg_part_number", @component.part.mfg_part_number], ["manufacturer", @component.part.manufacturer], ["description", @component.part.description], ["notes", @component.part.notes],
      ["optional_field_1", @component.part.optional_field_1], ["optional_field_2", @component.part.optional_field_2] ]

    fields.each do |field|
      if field[0] == "manufacturer"
        select @component.part.manufacturer.name, from: field[0]
      else
        fill_in field[0], with: field[1]
      end
      click_on "Apply", match: :first

      assert_text "brb101"

      click_on "Reset", match: :first

      assert_text "brb101"
    end

    fields = [["cost_per_unit", [3.1, 4.1]], ["in_stock", [2, 2]]]
    fields.each do |field|
      fill_in field[0] + "_min", with: field[1][0]
      click_on "Apply", match: :first

      assert_text "brb101"

      fill_in field[0] + "_max", with: field[1][1]
      click_on "Apply", match: :first

      assert_text "brb101"
      assert_no_text "gbc101"

      fill_in field[0] + "_min", with: ""
      click_on "Apply", match: :first

      assert_text "brb101"
      assert_no_text "gbc101"

      click_on "Reset", match: :first
    end

    assert_text "brb101"
  end

  test "should sort by column" do
    visit assembly_url(@assembly)

    assert_text "brb101"
    assert_text "gbc101"

    sort_array = ["Part", "Description", "Cost per Unit", "Quantity", "Total Cost"]
    sort_array.each do |sort|
      header = find("th[data-action='click->table-order#sort']", text: sort, match: :first, wait: 5)
      header.click
      assert_text "\u25b2", wait: 5
      assert_text(/brb101.*gbc101/m, wait: 5)
      header.click
      assert_text "\u25bc", wait: 5
      assert_text(/gbc101.*brb101/m, wait: 5)
    end
  end
end
