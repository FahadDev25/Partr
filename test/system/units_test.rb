# frozen_string_literal: true

require "application_system_test_case"

class UnitsTest < ApplicationSystemTestCase
  setup do
    attachments(:one).file.attach(io: File.open("test/fixtures/files/slip1.png"), filename: "slip1.png", content_type: "image/png")
    @unit = units(:failsafe)
    @aok = units(:vault_breaker)
    @no_received = units(:no_received)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit units_url
    assert_selector "h1", text: "Units"
  end

  test "should create unit" do
    visit job_url(@unit.job)
    click_on "Add Assembly"

    select @unit.job.name, from: "Job"
    select @unit.assembly.name, from: "Assembly"
    fill_in "Quantity", with: @unit.quantity
    click_on "Create Assembly"

    assert_text "Assembly was successfully created"
    click_on "Back"
  end

  test "should update Unit" do
    visit job_url(@unit.job)

    within("tr#unit_#{@unit.id}_row") do
      click_on "Edit", match: :first
    end

    select @unit.job.name, from: "Job"
    select @unit.assembly.name, from: "Assembly"
    fill_in "Quantity", with: @unit.quantity
    click_on "Update Assembly"

    assert_text "Assembly was successfully updated"
    click_on "Back"
  end

  test "should destroy Unit" do
    visit job_url(@unit.job)

    within("tr#unit_#{@unit.id}_row") do
      click_on "Remove", match: :first
    end

    assert_text "Assembly was successfully removed."
  end

  test "should fill unit part from inventory" do
    visit unit_url(@no_received)
    assert_no_text "1/1"
    click_on "Fill From Stock (#{@no_received.assembly.parts.first.in_stock.to_s.sub(/\.0+$/, '')})", match: :first

    @no_received.assembly.parts.first.reload
    assert_selector :css, 'a[href="' + parts_received_list_unit_path(@no_received, part_id: parts(:no_received_part).id) + '"]', text: "1"
    assert_equal @no_received.assembly.components.first.quantity * @no_received.quantity, @no_received.parts_received.first.quantity
    assert_equal 0, @no_received.assembly.parts.first.in_stock
  end

  test "should fill unit subassembly part from inventory" do
    unit = units(:only_subassembly)
    assembly = assemblies(:subassembly)
    part = assembly.parts.first
    visit unit_url(unit)
    assert_no_text "1/1"
    click_on "Fill from stock (#{part.in_stock.to_s.sub(/\.0+$/, '')})", match: :first

    part.reload
    assert_selector :css, 'a[href="' + subassembly_parts_received_list_unit_path(unit, part_id: part.id, unit_subassembly: { id: assembly.id, quantity: 1, sequence: [unit.assembly_id] }) + '"]', text: "1"
    assert_equal assembly.components.first.quantity * unit.quantity, unit.subassembly_parts_received({ id: assembly.id, quantity: 1, sequence: [unit.assembly_id] }).first.quantity
    assert_equal 2, part.in_stock
  end

  test "should not throw errors when exporting" do
    visit job_url(@aok.job)
    within("tr#unit_#{@aok.id}_row") do
      click_on "Export"
    end
    within("div#unit-export") do
      select "PDF", from: "File type"
      click_on "Export"
    end

    visit job_url(@aok.job)
    within("tr#unit_#{@aok.id}_row") do
      click_on "Export"
    end
    within("div#unit-export") do
      select "CSV", from: "File type"
      click_on "Export"
    end
  end

  test "should display unit subassemblies" do
    visit unit_url(@aok)
    assert_text "Apparatus of Kwalish > Control Panel"
    assert_text "lev123"
    assert_text "dia123"
    assert_text "Apparatus of Kwalish > Control Panel > Switch Array"
    assert_text "swi123"
  end
end
