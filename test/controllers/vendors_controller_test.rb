# frozen_string_literal: true

require "test_helper"

class VendorsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @vendor = vendors(:warner_bros)
    @empty = vendors(:empty)
    @user = users(:admin)
    sign_in @user
    @user.current_team = @team = teams(:trapsmiths)
  end

  test "should get index" do
    get vendors_url
    assert_response :success
  end

  test "should get new" do
    get new_vendor_url
    assert_response :success
  end

  test "should create vendor" do
    assert_difference("Vendor.count") do
      post vendors_url, params: {
        vendor: {
          name: "test",
          team_id: @team.id,
          vendor_address_attributes: {
            address_1: @vendor.vendor_address&.address_1,
            address_2: @vendor.vendor_address&.address_2,
            city: @vendor.vendor_address&.city,
            state: @vendor.vendor_address&.state,
            zip_code: @vendor.vendor_address&.zip_code
          },
        }
      }
    end

    assert_redirected_to vendor_url(Vendor.last)
  end

  test "should show vendor" do
    get vendor_url(@vendor)
    assert_response :success
  end

  test "should get edit" do
    get edit_vendor_url(@vendor)
    assert_response :success
  end

  test "should update vendor" do
    patch vendor_url(@vendor), params: {
      vendor: {
        name: @vendor.name,
        vendor_address_attributes: {
          address_1: @vendor.vendor_address&.address_1,
          address_2: @vendor.vendor_address&.address_2,
          city: @vendor.vendor_address&.city,
          state: @vendor.vendor_address&.state,
          zip_code: @vendor.vendor_address&.zip_code
        },
      }
    }
    assert_redirected_to vendor_url(@vendor)
  end

  test "should destroy vendor with no associated manufacturers" do
    assert_difference("Vendor.count", -1) do
      delete vendor_url(@empty)
    end

    assert_redirected_to vendors_url
  end

  test "should not destroy vendor with associated manufacturers" do
    assert_no_difference("Vendor.count") do
      delete vendor_url(@vendor)
    end

    assert_redirected_to vendor_url(@vendor)
  end
end
