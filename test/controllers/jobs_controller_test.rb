# frozen_string_literal: true

require "test_helper"

class JobsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @job = jobs(:trap)
    @job2 = jobs(:empty_job)
    @assembly_sdc = assemblies(:self_destruct_console)
    @assembly_aok = assemblies(:aok)
    @user = users(:admin)
    sign_in @user
    @user.current_team = teams(:trapsmiths)
    @team = teams(:trapsmiths)
  end

  test "should get index" do
    get team_jobs_url(@team)
    assert_response :success
  end

  test "should get new" do
    get new_team_job_url(@team)
    assert_response :success
  end

  test "should create job" do
    assert_difference("Job.count") do
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
            default_tax_rate: @job.default_tax_rate,
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

    assert_redirected_to job_url(Job.last)
  end

  test "should show job" do
    get job_url(@job)
    assert_response :success
  end

  test "should get edit" do
    get edit_job_url(@job)
    assert_response :success
  end

  test "should update job" do
    patch job_url(@job),
      params: {
        job: {
          job_number: "#{@job.job_number}_2",
          customer_id: @job.customer_id,
          deadline: @job.deadline,
          name: "#{@job.name}test",
          start_date: @job.start_date,
          status: @job.status,
          total_cost: @job.total_cost,
          default_tax_rate: @job.default_tax_rate,
          jobsite_attributes: {
            address_1: @job.jobsite&.address_1,
            address_2: @job.jobsite&.address_2,
            city: @job.jobsite&.city,
            state: @job.jobsite&.state,
            zip_code: @job.jobsite&.zip_code
          },
        }
      }
    assert_redirected_to job_url(@job)
  end

  test "should destroy job with no associated orders" do
    assert_difference("Job.count", -1) do
      delete job_url(@job2)
    end

    assert_redirected_to team_jobs_url(@team)
  end

  test "should not destroy job with associated orders" do
    assert_no_difference("Job.count") do
      delete job_url(@job)
    end

    assert_redirected_to job_url(@job)
  end

  test "should add multiple different assemblies" do
    @job2.add_assembly(@assembly_aok, 1, @team.organization).save!
    @job2.add_assembly(@assembly_sdc, 2, @team.organization).save!

    assert_equal(2, @job2.units.length)
    assert_equal @job2.total_cost, @assembly_aok.total_cost + (2 * @assembly_sdc.total_cost)
  end

  test "should combine duplicate assemblies" do
    @job2.add_assembly(@assembly_aok, 1, @team.organization).save!
    @job2.add_assembly(@assembly_aok, 1, @team.organization).save!

    assert_equal(1, @job2.units.length)
    assert_equal(2, @job2.units[0].quantity)
    assert_equal @job2.total_cost, 2 * @assembly_aok.total_cost
  end
end
