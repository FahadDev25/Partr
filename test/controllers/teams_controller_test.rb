# frozen_string_literal: true

require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @team = teams(:trapsmiths)
    @empty_team = teams(:empty)
    @user = users(:admin)
    @bob = users(:bob)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @bob.current_team = teams(:submersibles)
  end

  test "should get index" do
    get teams_url
    assert_response :success
  end

  test "should get new" do
    get new_team_url
    assert_response :success
  end

  test "should create team" do
    assert_difference("Team.count") do
      post teams_url, params: {
        team: {
          name: @team.name,
          organization_id: @team.organization_id,
          team_address_attributes: {
            address_1: @team.team_address&.address_1,
            address_2: @team.team_address&.address_2,
            city: @team.team_address&.city,
            state: @team.team_address&.state,
            zip_code: @team.team_address&.zip_code
          },
          billing_address_attributes: {
            address_1: @team.billing_address&.address_1,
            address_2: @team.billing_address&.address_2,
            city: @team.billing_address&.city,
            state: @team.billing_address&.state,
            zip_code: @team.billing_address&.zip_code
          },
          phone_number: @team.phone_number,
          use_org_addr: @team.use_org_addr,
          use_org_phone: @team.use_org_phone,
          team_role_id: @team.team_role_id
        },
        share_jobs_with: Team.all.pluck(:id).join(","),
        share_orders_with: Team.all.pluck(:id).join(","),
        share_shipments_with: Team.all.pluck(:id).join(","),
        share_parts_with: Team.all.pluck(:id).join(",")
      }
    end

    assert_redirected_to team_url(Team.last)
  end

  test "should show team" do
    get team_url(@team)
    assert_response :success
  end

  test "should get edit" do
    get edit_team_url(@team)
    assert_response :success
  end

  test "should update team" do
    patch team_url(@team), params: {
      team: {
        name: @team.name,
        organization_id: @team.organization_id,
        team_address_attributes: {
          address_1: @team.team_address&.address_1,
          address_2: @team.team_address&.address_2,
          city: @team.team_address&.city,
          state: @team.team_address&.state,
          zip_code: @team.team_address&.zip_code
        },
        billing_address_attributes: {
          address_1: @team.billing_address&.address_1,
          address_2: @team.billing_address&.address_2,
          city: @team.billing_address&.city,
          state: @team.billing_address&.state,
          zip_code: @team.billing_address&.zip_code
        },
        phone_number: @team.phone_number,
        use_org_addr: @team.use_org_addr,
        use_org_phone: @team.use_org_phone
      },
      share_jobs_with: Team.all.pluck(:id).join(","),
      share_orders_with: Team.all.pluck(:id).join(","),
      share_shipments_with: Team.all.pluck(:id).join(","),
      share_parts_with: Team.all.pluck(:id).join(",")
    }
    assert_redirected_to team_url(@team)
  end

  test "should destroy team" do
    assert_difference("Team.count", -1) do
      delete team_url(@empty_team)
    end

    assert_redirected_to teams_url
  end

  test "should not allow user to access team they aren't part of" do
    sign_out @user
    sign_in @bob

    get team_url(@team)
    assert_redirected_to home_team_path(@bob.current_team)
  end
end
