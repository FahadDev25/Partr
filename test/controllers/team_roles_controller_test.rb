# frozen_string_literal: true

require "test_helper"

class TeamRolesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @team_role = team_roles(:default)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
  end

  test "should get index" do
    get team_roles_url
    assert_response :success
  end

  test "should get new" do
    get new_team_role_url
    assert_response :success
  end

  test "should create team_role" do
    assert_difference("TeamRole.count") do
      post team_roles_url, params: { team_role: { all_job: @team_role.all_job, all_order: @team_role.all_order, all_shipment: @team_role.all_shipment, create_destroy_job: @team_role.create_destroy_job, organization_id: @team_role.organization_id } }
    end

    assert_redirected_to team_role_url(TeamRole.last)
  end

  test "should show team_role" do
    get team_role_url(@team_role)
    assert_response :success
  end

  test "should get edit" do
    get edit_team_role_url(@team_role)
    assert_response :success
  end

  test "should update team_role" do
    patch team_role_url(@team_role), params: { team_role: { all_job: @team_role.all_job, all_order: @team_role.all_order, all_shipment: @team_role.all_shipment, create_destroy_job: @team_role.create_destroy_job, organization_id: @team_role.organization_id } }
    assert_redirected_to team_role_url(@team_role)
  end

  test "should not destroy team_role with associated teams" do
    assert_no_difference("TeamRole.count") do
      delete team_role_url(@team_role)
    end

    assert_redirected_to team_role_url(@team_role)
  end

  test "should destroy team_role without associated teams" do
    assert_difference("TeamRole.count", -1) do
      delete team_role_url(team_roles(:unused))
    end

    assert_redirected_to team_roles_url
  end

  test "role without job create/destroy should not be able to create/destroy jobs" do
    @user.current_team = @team = teams(:empty)
    @user.save!
    @job = jobs(:trap)
    @job2 = jobs(:empty_job)

    assert_no_difference("Job.count") do
      post team_jobs_url(@team),
        params: {
          job: {
            job_number: "#{@job.job_number}_2",
            customer_id: @job.customer_id,
            deadline: @job.deadline,
            name: "#{@job.name}test",
            start_date: @job.start_date,
            status: @job.status,
            total_cost: @job.total_cost,
            team_id: @team.id,
            jobsite_attributes: {
              address_1: @job.jobsite&.address_1,
              address_2: @job.jobsite&.address_2,
              city: @job.jobsite&.city,
              state: @job.jobsite&.state,
              zip_code: @job.jobsite&.zip_code
            },
          }
        }
    end

    assert_redirected_to team_jobs_url(@team)

    assert_no_difference("Job.count") do
      delete job_url(@job2)
    end

    assert_redirected_to team_jobs_url(@team)
  end
end
