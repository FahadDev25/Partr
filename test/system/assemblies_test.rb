# frozen_string_literal: true

require "application_system_test_case"

class AssembliesTest < ApplicationSystemTestCase
  setup do
    @assembly = assemblies(:self_destruct_console)
    @empty = assemblies(:empty_assembly)
    @aok = assemblies(:aok)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit assemblies_url
    assert_selector "h1", text: "Assemblies"
  end

  test "should create assembly" do
    visit assemblies_url
    click_on "New Assembly"

    fill_in "Name", with: "#{@assembly.name}test"
    tom_select teams(:submersibles).name, from: "Share with"
    click_on "Create Assembly"

    assert_text "Assembly was successfully created"
    click_on "Back"
  end

  test "should update Assembly" do
    visit assembly_url(@assembly)
    click_on "Edit This Assembly", match: :first

    fill_in "Name", with: @assembly.name
    tom_select teams(:empty).name, from: "Share with"
    click_on "Update Assembly"

    assert_text "Assembly was successfully updated"
    click_on "Back"
  end

  test "should destroy Assembly with no associated jobs or shipments" do
    visit assembly_url(@empty)
    accept_confirm do
      click_on "Destroy This Assembly", match: :first
    end

    assert_text "Assembly was successfully destroyed"
  end

  test "should not destroy Assembly with associated jobs or shipments" do
    visit assembly_url(@assembly)
    accept_confirm do
      click_on "Destroy This Assembly", match: :first
    end

    assert_text "Cannot destroy Assembly with associated Jobs or Shipments"
  end

  test "should not throw errors when exporting" do
    visit assembly_url(@aok)
    click_on "Export", match: :first
    within("div#assembly-export") do
      select "PDF", from: "File type"
      click_on "Export"
    end

    visit assembly_url(@aok)
    click_on "Export", match: :first
    within("div#assembly-export") do
      select "CSV", from: "File type"
      click_on "Export"
    end
  end

  test "should show subassemblies for assembly" do
    visit assembly_url(@aok)
    assert_text "Control Panel"

    click_on "Control Panel", match: :first
    assert_text "Switch Array"
  end

  test "should search and filter the index" do
    visit assemblies_url
    assert_text @assembly.name

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @assembly.name, :enter

    assert_no_text @empty.name
    assert_text @assembly.total_quantity.to_s.sub(/\.0+$/, "")

    click_on "\u2716", match: :first

    assert_text @empty.name
    assert_text @aok.name
    assert_text @assembly.name

    click_on "Filters", match: :first

    fields = [ ["name", @assembly.name], ["customer", @assembly.customer] ]

    fields.each do |field|
      if field[0] == "customer"
        select @assembly.customer.name, from: field[0]
      else
        fill_in field[0], with: field[1]
      end
      click_on "Apply", match: :first

      assert_text @assembly.name
      assert_no_text @aok.name
      assert_no_text @empty.name

      click_on "Reset", match: :first

      assert_text @assembly.name
      assert_text @aok.name
      assert_text @empty.name
    end

    fields = [["total_cost", [@assembly.total_cost, @assembly.total_cost]], ["total_components", [@assembly.total_components - 1, @assembly.total_components + 1]],
              ["total_quantity", [@assembly.total_quantity - 1, @assembly.total_quantity + 1]]]
    fields.each do |field|
      fill_in field[0] + "_min", with: field[1][0]
      click_on "Apply", match: :first

      assert_text @assembly.name
      field[0] == "total_cost" ? (assert_no_text @aok.name) : (assert_text @aok.name)
      assert_no_text @empty.name

      fill_in field[0] + "_max", with: field[1][1]
      click_on "Apply", match: :first

      assert_text @assembly.name
      field[0] == "total_cost" ? (assert_no_text @aok.name) : (assert_text @aok.name)
      assert_no_text @empty.name

      fill_in field[0] + "_min", with: ""
      click_on "Apply", match: :first

      assert_text @assembly.name
      assert_text @aok.name
      assert_text @empty.name

      click_on "Reset", match: :first

      assert_text @assembly.name
      assert_text @aok.name
      assert_text @empty.name
    end

    assert_text @assembly.name
    assert_text @aok.name
    assert_text @empty.name
  end

  test "should sort index by column" do
    visit assemblies_url

    assert_text @assembly.name
    assert_text @empty.name

    sort_array = [["Name", [@empty.name, @assembly.name]], ["Total Cost", [@empty.name, @assembly.name]],
                  ["Total Components", [@empty.name, @assembly.name]], ["Total Quantity", [@empty.name, @assembly.name]]]
    sort_array.each do |sort|
      header = find("th[data-action='click->table-order#sort']", text: sort[0], match: :first, wait: 5)
      header.click
      assert_text(/#{sort[1][0]}.*#{sort[1][1]}/m, wait: 5)
      header.click
      assert_text(/#{sort[1][1]}.*#{sort[1][0]}/m, wait: 5)
    end
  end
end
