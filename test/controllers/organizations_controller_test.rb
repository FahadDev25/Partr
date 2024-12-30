# frozen_string_literal: true

require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @organization = organizations(:artificers)
    @empty_org = organizations(:empty_org)
    @user = users(:johnsmith)
    @admin = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
  end

  test "should not get new" do
    get new_organization_url
    assert_redirected_to home_team_url(@team)
  end

  test "should not create organization outside of signup" do
    assert_no_difference("Organization.count") do
      post organizations_url, params: { organization: { abbr_name: @organization.abbr_name, name: @organization.name + "test", user_id: @user.id } }
    end

    assert_redirected_to home_team_url(@team)
  end

  test "should show organization" do
    get organization_url(@organization)
    assert_response :success
  end

  test "should get edit" do
    get edit_organization_url(@organization)
    assert_response :success
  end

  test "should update organization" do
    patch organization_url(@organization),
      params: {
        organization: {
          abbr_name: @organization.abbr_name, name: @organization.name,
          hq_address_attributes: {
            address_1: @organization.hq_address&.address_1,
            address_2: @organization.hq_address&.address_2,
            city: @organization.hq_address&.city,
            state: @organization.hq_address&.state,
            zip_code: @organization.hq_address&.zip_code
          },
          billing_address_attributes: {
            address_1: @organization.billing_address&.address_1,
            address_2: @organization.billing_address&.address_2,
            city: @organization.billing_address&.city,
            state: @organization.billing_address&.state,
            zip_code: @organization.billing_address&.zip_code
          },
          phone_number: @organization.phone_number,
          fax_number: @organization.fax_number
        }
      }
    assert_redirected_to organization_url(@organization)
  end

  test "should destroy organization" do
    assert_difference("Organization.count", -1) do
      delete organization_url(@organization)
    end

    assert_redirected_to organizations_url
  end

  test "should not allow non-owners to access organization" do
    sign_out @user
    sign_in @admin
    @admin.current_team = @team

    get organization_url(@organization)
    assert_redirected_to home_team_path(@team)
  end
end
