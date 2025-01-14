# frozen_string_literal: true

require "application_system_test_case"

class EmployeesTest < ApplicationSystemTestCase
  setup do
    @employee = employees(:art_bob)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "visiting the index" do
    visit employees_url
    assert_selector "h1", text: "Employees"
  end

  test "should create employee" do
    visit employees_url
    click_on "New Employee"

    fill_in "Organization", with: @employee.organization_id
    fill_in "User", with: @employee.user_id
    click_on "Create Employee"

    assert_text "Employee was successfully created"
    click_on "Back"
  end

  test "should update Employee" do
    visit employee_url(@employee)
    click_on "Edit This Employee", match: :first

    fill_in "Organization", with: @employee.organization_id
    fill_in "User", with: @employee.user_id
    click_on "Update Employee"

    assert_text "Employee was successfully updated"
    click_on "Back"
  end

  test "should destroy Employee" do
    visit employee_url(@employee)
    click_on "Destroy This Employee", match: :first

    assert_text "Employee was successfully destroyed"
  end
end
