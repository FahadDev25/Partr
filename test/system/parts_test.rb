# frozen_string_literal: true

require "application_system_test_case"

class PartsTest < ApplicationSystemTestCase
  setup do
    parts.each { |p| p.send(:generate_qr_code) }
    @part = parts(:big_red_button)
    @empty = parts(:empty)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit parts_url
    assert_selector "h1", text: "Parts"
    assert_css ".staleness-fresh"
    assert_css ".staleness-warn"
    assert_css ".staleness-stale"
  end

  test "should search and filter the index" do
    visit parts_url
    assert_text "brb101"

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @part.mfg_part_number, :enter

    assert_no_text "gbc101"
    assert_text "brb101"

    click_on "\u2716", match: :first

    assert_text "brb101"
    assert_text "gbc101"
    assert_text "bmc123"
    assert_text "000-000"

    click_on "Filters", match: :first

    fields = [ ["mfg_part_number", @part.mfg_part_number], ["manufacturer", @part.manufacturer], ["description", @part.description], ["notes", @part.notes],
      ["optional_field_1", @part.optional_field_1], ["optional_field_2", @part.optional_field_2] ]

    fields.each do |field|
      if field[0] == "manufacturer"
        select @part.manufacturer.name, from: field[0]
      else
        fill_in field[0], with: field[1]
      end
      click_on "Apply", match: :first

      assert_text "big and red"
      (field[0] == "manufacturer") ? (assert_text "gbc101") : (assert_no_text "gbc101")
      assert_no_text "bmc123"
      assert_no_text "000-000"

      click_on "Reset", match: :first

      assert_text "brb101"
      assert_text "gbc101"
      assert_text "bmc123"
      assert_text "000-000"
    end

    fields = [["cost_per_unit", [3.1, 4.1]], ["in_stock", [2, 2]]]
    fields.each do |field|
      fill_in field[0] + "_min", with: field[1][0]
      click_on "Apply", match: :first

      assert_text "brb101"
      assert_text "gbc101"
      assert_text "bmc123"
      assert_no_text "000-000"

      fill_in field[0] + "_max", with: field[1][1]
      click_on "Apply", match: :first

      assert_text "brb101"
      assert_no_text "gbc101"
      assert_no_text "bmc123"
      assert_no_text "000-000"

      fill_in field[0] + "_min", with: ""
      click_on "Apply", match: :first

      assert_text "brb101"
      assert_no_text "gbc101"
      assert_no_text "bmc123"
      assert_text "000-000"

      click_on "Reset", match: :first
    end

    assert_text "brb101"
    assert_text "gbc101"
    assert_text "bmc123"
    assert_text "000-000"
  end

  test "should sort index by column" do
    visit parts_url

    assert_text "brb101"
    assert_text "bmc123"

    sort_array = [["Mfg Part Number", ["bmc123", "brb101"]], ["Manufacturer", ["brb101", "bmc123"]], ["Description", ["bmc123", "brb101"]],
                  ["Cost per Unit", ["brb101", "bmc123"]], ["In Stock", ["brb101", "bmc123"]], ["Notes", ["brb101", "bmc123"]],
                  ["UL File Number", ["brb101", "bmc123"]], ["UL CCN", ["brb101", "bmc123"]]]
    sort_array.each do |sort|
      header = find("th[data-action='click->table-order#sort']", text: sort[0], match: :first, wait: 5)
      header.trigger("click")
      assert_text(/#{sort[1][0]}.*#{sort[1][1]}/m, wait: 5)
      header.trigger("click")
      assert_text(/#{sort[1][1]}.*#{sort[1][0]}/m, wait: 5)
    end
  end

  test "should create part" do
    visit parts_url
    click_on "New Part"

    within "div#modal-content" do
      tom_select @part.manufacturer.name, from: "Manufacturer"
      fill_in "Cost per unit", with: @part.cost_per_unit
      fill_in "Description", with: @part.description
      fill_in "In stock", with: @part.in_stock
      fill_in "Notes", with: @part.notes
      fill_in "Mfg part number", with: @part.mfg_part_number + "_2"
      tom_select @part.shared_teams.pluck(:name), from: "Share with"
      click_on "Create Part"
    end

    assert_text "Part was successfully created"
  end

  test "should update Part" do
    visit parts_url
    assert_text "brb101"

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @part.mfg_part_number, :enter

    assert_no_text "000-000"
    assert_text "brb101"

    click_on @part.org_part_number

    within("div#modal-header") do
      click_on "Edit", match: :first
    end

    assert_difference "@part.shared_teams.count", -1 do
      within "div#modal-content" do
        tom_select @part.manufacturer.name, from: "Manufacturer"
        fill_in "Cost per unit", with: @part.cost_per_unit
        fill_in "Description", with: @part.description
        fill_in "In stock", with: @part.in_stock
        fill_in "Notes", with: @part.notes
        fill_in "Mfg part number", with: @part.mfg_part_number
        first("a.remove").click
        click_on "Update Part"
        assert_text "Part was successfully updated"
      end
    end
  end

  test "should update stock through modal" do
    visit part_url(@part)
    click_on "\u00b1", match: :first

    select "Set", from: "mode"
    fill_in "Amount", with: 5

    click_on "Submit"

    @part.reload
    assert_equal 5, @part.in_stock

    click_on "\u00b1", match: :first

    select "Add", from: "mode"
    fill_in "Amount", with: 5

    click_on "Submit"

    @part.reload
    assert_equal 10, @part.in_stock

    click_on "\u00b1", match: :first

    select "Subtract", from: "mode"
    fill_in "Amount", with: 5

    click_on "Submit"

    @part.reload
    assert_equal 5, @part.in_stock
  end

  test "should destroy Part with no associated components, line_items, or parts_received" do
    visit parts_url
    assert_text "brb101"

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @empty.mfg_part_number, :enter

    assert_no_text "brb101"
    assert_text "000-000"

    click_on @empty.org_part_number

    assert_text "Delete"

    accept_confirm do
      click_on "Delete", match: :first
    end

    assert_text "Part was successfully destroyed"
  end

  test "should not destroy Part with associated components, line_items, or parts_received" do
    visit parts_url
    assert_text "brb101"

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @part.mfg_part_number, :enter

    assert_no_text "000-000"
    assert_text "brb101"

    click_on @part.org_part_number

    within("div#part_#{@part.id}_edit_delete") do
      accept_confirm do
        click_on "Delete", match: :first
      end
    end

    assert_text "Cannot destroy Part with associated Jobs, Assemblies, Orders, or Shipments."
  end

  test "should not throw errors when generating qr codes pdf" do
    visit parts_url
    click_on "QR Codes PDF"
  end

  test "quick links should work" do
    visit quick_links_part_url(@part)
    assert_text @part.label

    click_on "Show Part"
    assert_text @part.description
    find("button[aria-label=close]").click
    assert_no_text @part.org_part_number

    click_on "Add to Job"
    assert_text "Add Part"
    find("button[aria-label=close]").click
    assert_no_text "Add Part"

    click_on "Add to Assembly"
    assert_text "New Component"
    find("button[aria-label=close]").click
    assert_no_text "New Component"
  end

  test "should not throw errors when exporting" do
    visit parts_url
    click_on "CSV Export"
  end
end
