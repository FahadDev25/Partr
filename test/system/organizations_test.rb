# frozen_string_literal: true

require "application_system_test_case"

class OrganizationsTest < ApplicationSystemTestCase
  setup do
    @organization = organizations(:artificers)
    @empty_org = organizations(:empty_org)
    @empty_user = users(:empty)
    @user = users(:johnsmith)
    @admin = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end

  test "should update Organization" do
    visit organization_url(@organization)
    click_on "Edit This Organization", match: :first

    fill_in "Abbr name", with: @organization.abbr_name
    fill_in "Name", with: @organization.name
    within "div#hq_address_fields" do
      fill_in "Address 1", with: @organization.hq_address&.address_1
      fill_in "Address 2", with: @organization.hq_address&.address_2
      fill_in "City", with: @organization.hq_address&.city
      select @organization.hq_address&.state, from: "State"
      fill_in "Zip code", with: @organization.hq_address&.zip_code
    end
    within "div#billing_address_fields" do
      fill_in "Address 1", with: @organization.billing_address&.address_1
      fill_in "Address 2", with: @organization.billing_address&.address_2
      fill_in "City", with: @organization.billing_address&.city
      select @organization.billing_address&.state, from: "State"
      fill_in "Zip code", with: @organization.billing_address&.zip_code
    end
    fill_in "Phone number", with: @organization.phone_number
    click_on "Update Organization"

    assert_text "Organization was successfully updated"
  end

  test "should destroy Organization" do
    skip("figure out org deletion")
    visit organization_url(@empty_org)
    click_on "Destroy this organization", match: :first

    assert_text "Organization was successfully destroyed"
  end

  test "should prevent non-owner users from accessing organization" do
    sign_out @user
    sign_in @admin
    @admin.current_team = teams(:trapsmiths)

    visit organization_url(@organization)

    assert_text "You are not authorized to access this organization"
  end
end
