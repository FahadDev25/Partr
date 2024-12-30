# frozen_string_literal: true

require "test_helper"

class TeamMembersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @team_member = team_members(:trap_admin)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
  end

  test "should get index" do
    get team_team_members_url(@team)
    assert_response :success
  end

  test "should get new" do
    get new_team_team_member_url(@team)
    assert_response :success
  end

  test "should create team_member" do
    assert_difference("TeamMember.count") do
      post team_team_members_url(@team), params: { team_member: { organization_id: @team_member.organization_id, team_id: @team_member.team_id, user_id: @team_member.user_id } }
    end

    assert_redirected_to team_url(TeamMember.last.team)
  end

  test "should show team_member" do
    get team_member_url(@team_member)
    assert_response :success
  end

  test "should get edit" do
    get edit_team_member_url(@team_member)
    assert_response :success
  end

  test "should update team_member" do
    patch team_member_url(@team_member),
          params: { team_member: { organization_id: @team_member.organization_id, team_id: @team_member.team_id, user_id: @team_member.user_id } }
    assert_redirected_to team_url(@team)
  end

  test "should destroy team_member" do
    assert_difference("TeamMember.count", -1) do
      delete team_member_url(@team_member)
    end

    assert_redirected_to team_url(@team)
  end
end
