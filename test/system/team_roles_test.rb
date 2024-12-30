# frozen_string_literal: true

require "application_system_test_case"

class TeamRolesTest < ApplicationSystemTestCase
  setup do
    @team_role = team_roles(:default)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit team_roles_url
    assert_selector "h1", text: "Team roles"
  end

  test "should create team role" do
    visit team_roles_url
    click_on "New team role"

    check "Access all Jobs" if @team_role.all_job
    check "Access all Orders" if @team_role.all_order
    check "Access all Shipments" if @team_role.all_shipment
    check "Create and destroy Jobs" if @team_role.create_destroy_job
    click_on "Create Team role"

    assert_text "Team role was successfully created"
    click_on "Back"
  end

  test "should update Team role" do
    visit team_role_url(@team_role)
    click_on "Edit this team role", match: :first

    check "Access all Jobs" if @team_role.all_job
    check "Access all Orders" if @team_role.all_order
    check "Access all Shipments" if @team_role.all_shipment
    check "Create and destroy Jobs" if @team_role.create_destroy_job
    click_on "Update Team role"

    assert_text "Team role was successfully updated"
    click_on "Back"
  end

  test "should destroy Team role" do
    visit team_role_url(team_roles(:unused))
    click_on "Destroy this team role", match: :first

    assert_text "Team role was successfully destroyed"
  end

  test "role with all_order/job/shipment should give access to all order/job/shipment" do
    @user.current_team = @team = teams(:artificer_accounting)
    @user.save!

    visit team_jobs_url(@team)
    assert_text jobs(:trap).name
    assert_text jobs(:heist).name

    visit team_orders_url(@team)
    assert_text orders(:button_order).po_number
    assert_text orders(:claws_order).po_number

    visit team_shipments_url(@team)
    assert_text shipments(:button_shipment).shipping_number
    assert_text shipments(:claws_shipment).shipping_number
  end

  test "role without job create/destroy should not be able to create/destroy jobs" do
    @user.current_team = @team = teams(:empty)
    @user.save!
    @job = jobs(:trap)
    attachments(:one).file.attach(io: File.open("test/fixtures/files/slip1.png"), filename: "slip1.png", content_type: "image/png") # to make sure attachment exists

    visit team_jobs_url(@team)
    click_on "New Job", match: :first
    assert_text "Team does not have create/destroy job permissions"

    SharedRecord.create!(shareable_type: "Job", shareable_id: @job.id, team_id: @team.id, organization_id: @team.organization_id)
    visit job_url(@job)
    accept_confirm { click_on "Destroy This Job" }
    assert_text "Team does not have create/destroy job permissions"
  end
end
