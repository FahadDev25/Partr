# frozen_string_literal: true

require "application_system_test_case"

class SharedRecordsTest < ApplicationSystemTestCase
  setup do
    @jim = users(:jim)
    @jim.current_team = @jim_team = teams(:trapsmiths)
    @jim.save!
    @bob = users(:bob)
    @bob.current_team = @bob_team = teams(:submersibles)
    @bob.save!
    @job = jobs(:trap)
    @order = orders(:button_order)
    @shipment = shipments(:button_shipment)
    @assembly = assemblies(:aok)
    @part = parts(:big_meaty_claw)
    @order = orders(:claws_order)
  end

  test "should be able to share jobs/orders/shipments between teams" do
    sign_in @jim
    visit team_jobs_url(@jim_team)
    click_on "New Job"

    fill_in "Job number", with: "#{@job.job_number}_shared"
    select @job.customer.name, from: "Customer"
    fill_in "Deadline", with: @job.deadline
    fill_in "Name", with: "#{@job.name}_shared"
    fill_in "Start date", with: @job.start_date
    select @job.status, from: "Status"
    fill_in "Address 1", with: @job.jobsite&.address_1
    fill_in "Address 2", with: @job.jobsite&.address_2
    fill_in "City", with: @job.jobsite&.city
    select @job.jobsite&.state, from: "State"
    fill_in "Zip code", with: @job.jobsite&.zip_code
    tom_select @bob_team.name, from: "Share with"
    click_on "Create Job"

    assert_text "Job was successfully created."
    job = Job.last

    sign_out @jim
    sign_in @bob

    visit team_jobs_url(@bob_team)
    assert_text "#{@job.name}_shared"

    visit job_url(job)
    assert_text "#{@job.name}_shared"
    click_on "Add Assembly"
    select @assembly.name, from: "Assembly"
    fill_in "Quantity", with: 2
    click_on "Create Assembly"

    assert_text "Assembly was successfully created."

    click_on "Add Part"
    select @part.label, from: "Part"
    fill_in "Quantity", with: 2
    within("div#modal-content") { click_on "Add Part" }

    assert_text "Additional part was successfully created."

    click_on "Create Order"

    assert_field("order[tax_rate]", with: @jim_team.default_tax_rate)

    fill_in "Order date", with: @order.order_date
    assert_no_text vendors(:empty).name
    assert_text @order.vendor.name
    tom_select @order.vendor.name, from: "Vendor"
    fill_in "Freight cost", with: @order.freight_cost
    fill_in "Tax rate", with: @order.tax_rate
    fill_in "Notes", with: @order.notes
    within("div#modal-content") { click_on "Create Order" }

    assert_text "Order was successfully created"

    order = Order.last
    sign_out @bob
    sign_in @jim

    visit team_orders_url(@jim_team)
    assert_text order.po_number

    visit order_url(order)
    click_on "Add Line Item"
    select @part.label, from: "Part"
    select @assembly.name, from: "Assembly"
    fill_in "Quantity", with: 2
    click_on "Create Line item"

    assert_text "Line item was successfully created."

    visit team_shipments_url(@jim_team)
    click_on "New Shipment"
    fill_in "Date received", with: @shipment.date_received
    fill_in "From", with: @shipment.from
    select job.name, from: "Job"
    fill_in "Notes", with: @shipment.notes
    select order.name, from: "Order"
    fill_in "Shipping number", with: @shipment.shipping_number + "_shared"
    click_on "Create Shipment"

    assert_text "Shipment was successfully created"

    shipment = Shipment.last

    sign_out @jim
    sign_in @bob

    visit team_shipments_url(@bob_team)
    assert_text shipment.shipping_number

    visit shipment_url(shipment)
    click_on "Add Part Received"

    tom_select "#{@part.label} (#{@assembly.name})", from: "Line Item"
    fill_in "Quantity", with: 2
    click_on "Create Part received"

    assert_text "Part received was successfully created."
  end
end
