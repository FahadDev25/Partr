# frozen_string_literal: true

require "application_system_test_case"

class TeamMembersTest < ApplicationSystemTestCase
  setup do
    @team_member = team_members(:trap_admin)
    @user = users(:admin)
    @empty_user = users(:empty)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit team_team_members_url(@team)
    assert_selector "h1", text: "Team Members"
  end

  test "should create team member" do
    visit team_url(@team)
    click_on "New Team Member"

    select @team.name, from: "Team"
    select @empty_user.username, from: "User"
    click_on "Create Team member"

    assert_text "Team member was successfully created"
    click_on "Back"
  end

  test "should update Team member" do
    visit team_url(@team)
    click_on "Edit", match: :first

    select @team.name, from: "Team"
    select @empty_user.username, from: "User"
    click_on "Update Team member"

    assert_text "Team member was successfully updated"
    click_on "Back"
  end

  test "should destroy Team member" do
    visit team_member_url(@team_member)
    click_on "Destroy This Team Member", match: :first

    assert_text "Team member was successfully destroyed"
  end
end
