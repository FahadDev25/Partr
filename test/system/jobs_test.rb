# frozen_string_literal: true

require "application_system_test_case"

class JobsTest < ApplicationSystemTestCase
  setup do
    @job = jobs(:trap)
    attachments(:one).file.attach(io: File.open("test/fixtures/files/slip1.png"), filename: "slip1.png", content_type: "image/png")
    @trap2 = jobs(:second_trap)
    @empty_job = jobs(:empty_job)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit team_jobs_url(@team)
    assert_selector "h1", text: "Jobs"
  end

  test "should create job" do
    visit team_jobs_url(@team)
    click_on "New Job"

    fill_in "Job number", with: "#{@job.job_number}test"
    select @job.customer.name, from: "Customer"
    fill_in "Deadline", with: @job.deadline
    fill_in "Name", with: "#{@job.name}test"
    fill_in "Start date", with: @job.start_date
    select @job.status, from: "Status"
    fill_in "Address 1", with: @job.jobsite&.address_1
    fill_in "Address 2", with: @job.jobsite&.address_2
    fill_in "City", with: @job.jobsite&.city
    select @job.jobsite&.state, from: "State"
    fill_in "Zip code", with: @job.jobsite&.zip_code
    fill_in "Default Tax Rate for Orders", with: @job.default_tax_rate
    click_on "Create Job"

    assert_text "Job was successfully created"
    click_on "Back"
  end

  test "should update Job" do
    visit job_url(@job)
    click_on "Edit This Job", match: :first

    fill_in "Job number", with: "#{@job.job_number}test"
    select @job.customer.name, from: "Customer"
    fill_in "Deadline", with: @job.deadline
    fill_in "Name", with: @job.name
    fill_in "Start date", with: @job.start_date
    select @job.status, from: "Status"
    fill_in "Address 1", with: @job.jobsite&.address_1
    fill_in "Address 2", with: @job.jobsite&.address_2
    fill_in "City", with: @job.jobsite&.city
    select @job.jobsite&.state, from: "State"
    fill_in "Zip code", with: @job.jobsite&.zip_code
    fill_in "Default Tax Rate for Orders", with: @job.default_tax_rate
    click_on "Update Job"

    assert_text "Job was successfully updated"
    click_on "Back"
  end

  test "should destroy Job with no associated orders" do
    visit job_url(@empty_job)
    accept_confirm do
      click_on "Destroy This Job", match: :first
    end

    assert_text "Job was successfully destroyed"
  end

  test "should not destroy Job with associated orders" do
    visit job_url(@job)
    accept_confirm do
      click_on "Destroy This Job", match: :first
    end

    assert_text "Cannot destroy job with associated orders."
  end

  test "should search and filter the index" do
    visit team_jobs_url(@team)
    assert_text @job.name
    assert_text @trap2.name

    search = find("input[data-action='input->search-filter#get_results']", id: "search")
    search.native.send_keys @job.name, :enter

    assert_no_text @trap2.name
    assert_text @job.customer.name

    click_on "\u2716", match: :first

    assert_text @trap2.name
    assert_text @job.name

    click_on "Filters", match: :first

    fields = [ ["name", @job.name], ["status", @job.status], ["customer", @job.customer], ["project_manager", @job.project_manager] ]

    fields.each do |field|
      if field[0] == "customer"
        select @job.customer.name, from: field[0]
      elsif field[0] == "project_manager"
        select @job.project_manager.username, from: field[0]
      elsif field[0] == "status"
        select @job.status, from: field[0]
      else
        fill_in field[0], with: field[1]
      end
      click_on "Apply", match: :first

      assert_text @job.name
      assert_no_text @trap2.name

      click_on "Reset", match: :first

      assert_text @job.name
      assert_text @trap2.name
    end

    fields = [["total_cost", [@job.total_cost - 1, @job.total_cost + 1]], ["start_date", [@job.start_date, @job.start_date]], ["deadline", [@job.deadline, @job.deadline]]]
    fields.each do |field|
      min_suffix = field[0] == "total_cost" ? "_min" : "_start"
      max_suffix = field[0] == "total_cost" ? "_max" : "_end"
      fill_in field[0] + min_suffix, with: field[1][0]
      click_on "Apply", match: :first

      assert_text @job.name
      assert_text @trap2.name

      fill_in field[0] + max_suffix, with: field[1][1]
      click_on "Apply", match: :first

      assert_text @job.name
      assert_no_text @trap2.name

      fill_in field[0] + min_suffix, with: ""
      click_on "Apply", match: :first

      assert_text @job.name
      assert_no_text @trap2.name

      click_on "Reset", match: :first

      assert_text @job.name
      assert_text @trap2.name
    end

    assert_text @job.name
    assert_text @trap2.name
  end

  test "should sort index by column" do
    visit team_jobs_url(@team)

    assert_text @job.name
    assert_text @trap2.name

    sort_array = [["Job Number", [@job.name, @trap2.name]], ["Name", [@job.name, @trap2.name]], ["Total Cost", [@job.name, @trap2.name]], ["Status", [@trap2.name, @job.name]],
                  ["Start Date", [@job.name, @trap2.name]], ["Deadline", [@job.name, @trap2.name]], ["Customer", [@trap2.name, @job.name]],
                  ["Project Manager", [@job.name, @trap2.name]]]
    sort_array.each do |sort|
      header = find("th[data-action='click->table-order#sort']", text: sort[0], match: :first, wait: 5)
      header.trigger("click")
      assert_text(/#{sort[1][0]}.*#{sort[1][1]}/m, wait: 10)
      header.trigger("click")
      assert_text(/#{sort[1][1]}.*#{sort[1][0]}/m, wait: 10)
    end
  end

  test "Should show pinned jobs on home page" do
    sign_out @user
    @user = users(:jim)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!

    visit home_team_url(@team)
    assert_text @user.pinned_jobs.first.job.job_number
  end

  test "Should pin and unpin job" do
    visit job_url(@job)

    click_on "Pin to Home"
    assert_text "Unpin"

    visit home_team_path(@team)
    assert_text @job.job_number

    visit job_url(@job)

    click_on "Unpin"
    assert_text "Pin to Home"

    visit home_team_path(@team)
    assert_no_text @job.job_number
  end
end
