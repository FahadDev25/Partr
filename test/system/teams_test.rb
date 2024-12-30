# frozen_string_literal: true

require "application_system_test_case"

class TeamsTest < ApplicationSystemTestCase
  setup do
    @team = teams(:trapsmiths)
    @empty_team = teams(:empty)
    @submersibles = teams(:submersibles)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit teams_url
    assert_selector "h1", text: "Teams"
  end

  test "should create team" do
    visit teams_url
    click_on "New Team"

    fill_in "Name", with: @team.name
    select @team.role.name, from: "Role"
    within "div#address_fields" do
      fill_in "Address 1", with: @team.team_address&.address_1
      fill_in "Address 2", with: @team.team_address&.address_2
      fill_in "City", with: @team.team_address&.city
      select @team.team_address&.state, from: "State"
      fill_in "Zip code", with: @team.team_address&.zip_code
    end
    within "div#billing_fields" do
      fill_in "Address 1", with: @team.billing_address&.address_1
      fill_in "Address 2", with: @team.billing_address&.address_2
      fill_in "City", with: @team.billing_address&.city
      select @team.billing_address&.state, from: "State"
      fill_in "Zip code", with: @team.billing_address&.zip_code
    end
    fill_in "Phone number", with: @team.phone_number
    click_on "Create Team"

    assert_text "Team was successfully created"
    click_on "Back"
  end

  test "should create team with org address and phone" do
    visit teams_url
    click_on "New Team"

    fill_in "Name", with: @team.name
    select @team.role.name, from: "Role"
    check name: "team[use_org_addr]"
    check name: "team[use_org_billing]"
    check name: "team[use_org_phone]"
    click_on "Create Team"

    assert_text "Team was successfully created"
    click_on "Back"
  end

  test "should update Team" do
    visit team_url(@team)
    click_on "Edit This Team", match: :first

    fill_in "Name", with: @team.name
    uncheck name: "team[use_org_addr]"
    uncheck name: "team[use_org_phone]"
    assert_text "Address"
    assert_text "Phone number"
    within "div#address_fields" do
      fill_in "Address 1", with: @team.team_address&.address_1
      fill_in "Address 2", with: @team.team_address&.address_2
      fill_in "City", with: @team.team_address&.city
      select @team.team_address&.state, from: "State"
      fill_in "Zip code", with: @team.team_address&.zip_code
    end
    fill_in "Phone number", with: @team.phone_number
    click_on "Update Team"

    assert_text "Team was successfully updated"
    click_on "Back"
  end

  test "should destroy Team" do
    visit team_url(@empty_team)
    click_on "Destroy This Team", match: :first

    assert_text "Team was successfully destroyed"
  end

  test "should search and filter the index" do
    visit teams_url
    assert_text @team.name
    assert_text @submersibles.name

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @team.name, :enter

    assert_no_text @submersibles.name
    assert_text @team.team_address&.address_1

    click_on "\u2716", match: :first

    assert_text @submersibles.name
    assert_text @team.name

    click_on "Filters", match: :first

    fields = [ ["name", @team.name], ["address", @team.team_address&.address_1], ["city", @team.team_address&.city], ["state", @team.team_address&.state],
               ["zip_code", @team.team_address&.zip_code], ["phone_number", @team.phone_number], ["default_unit", @team.default_unit],
               ["assembly_label", @team.assembly_label] ]

    fields.each do |field|
      if field[0] == "state"
        select @team.team_address&.state, from: field[0]
      else
        fill_in field[0], with: field[1]
      end
      click_on "Apply", match: :first

      assert_text @team.name
      assert_no_text @submersibles.name

      click_on "Reset", match: :first

      assert_text @team.name
      assert_text @submersibles.name
    end

    assert_text @team.name
    assert_text @submersibles.name
  end

  test "should sort index by column" do
    visit teams_url

    assert_text @team.name
    assert_text @submersibles.name

    sort_array = [["Name", [@team.name, @submersibles.name]], ["Address", [@submersibles.name, @team.name]], ["City", [@submersibles.name, @team.name]],
                  ["State", [@team.name, @submersibles.name]], ["Zip Code", [@submersibles.name, @team.name]], ["Phone Number", [@submersibles.name, @team.name]],
                  ["Default Unit", [@submersibles.name, @team.name]], ["Assembly Label", [[@team.name, @submersibles.name]]]]
    sort_array.each do |sort|
      header = find("th[data-action='click->table-order#sort']", text: sort[0], match: :first, wait: 5)
      header.trigger("click")
      assert_text(/#{sort[1][0]}.*#{sort[1][1]}/m, wait: 5)
      header.trigger("click")
      assert_text(/#{sort[1][1]}.*#{sort[1][0]}/m, wait: 5)
    end
  end
end
