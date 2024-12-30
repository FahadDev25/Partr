# frozen_string_literal: true

require "application_system_test_case"

class AdditionalPartsTest < ApplicationSystemTestCase
  setup do
    @button = additional_parts(:one_button)
    @claws = additional_parts(:extra_claws)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  # test "visiting the index" do
  #   visit additional_parts_url
  #   assert_selector "h1", text: "Additional parts"
  # end

  test "should create additional part" do
    visit job_url(@button.job)
    click_on "Add Part"

    select @claws.part.label, from: "Part"
    fill_in "Quantity", with: 1
    click_on "Add Part", match: :first

    assert_text @claws.part.label
    click_on "Back"
  end

  test "should update Additional part" do
    visit job_url(@button.job)
    click_on "Edit", match: :first

    select @button.job.name, from: "Job"
    select @claws.part.label, from: "Part"
    fill_in "Quantity", with: 1
    click_on "Update"

    assert_text "Additional part was successfully updated"
    click_on "Back"
  end

  test "should destroy Additional part" do
    visit job_url(@button.job)
    click_on "Remove", match: :smart
    assert_text "Additional part was successfully destroyed"
  end

  test "should fill Additional part from inventory" do
    visit job_url(@button.job)
    assert_no_text " \u2714"
    click_on "Fill From Stock (#{@button.part.in_stock.to_s.sub(/\.0+$/, '')})", match: :first

    @button.part.reload
    assert_text " \u2714"
    assert_equal @button.quantity, @button.parts_received.first.quantity
    assert_equal 1, @button.part.in_stock
  end
end
