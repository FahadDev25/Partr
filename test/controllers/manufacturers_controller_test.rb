# frozen_string_literal: true

require "test_helper"

class ManufacturersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @manufacturer = manufacturers(:acme)
    @useless = manufacturers(:makes_nothing)
    @user = users(:admin)
    sign_in @user
    @user.current_team = teams(:trapsmiths)
  end

  test "should get index" do
    get manufacturers_url
    assert_response :success
  end

  test "should get new" do
    get new_manufacturer_url
    assert_response :success
  end

  test "should create manufacturer" do
    assert_difference("Manufacturer.count") do
      post manufacturers_url,
           params: { manufacturer: { name: "#{@manufacturer.name}test", vendor_id: @manufacturer.vendor_id,
                                      team_id: @user.current_team.id, organization_id: @user.current_team.organization_id } }
    end

    assert_redirected_to manufacturer_url(Manufacturer.last)
  end

  test "should show manufacturer" do
    get manufacturer_url(@manufacturer)
    assert_response :success
  end

  test "should get edit" do
    get edit_manufacturer_url(@manufacturer)
    assert_response :success
  end

  test "should update manufacturer" do
    patch manufacturer_url(@manufacturer),
          params: { manufacturer: { name: @manufacturer.name, vendor_id: @manufacturer.vendor_id } }
    assert_redirected_to manufacturer_url(@manufacturer)
  end

  test "should destroy manufacturer with no associated parts" do
    assert_difference("Manufacturer.count", -1) do
      delete manufacturer_url(@useless)
    end

    assert_redirected_to manufacturers_url
  end

  test "should not destroy manufacturer with associated parts" do
    assert_no_difference("Manufacturer.count") do
      delete manufacturer_url(@manufacturer)
    end

    assert_redirected_to manufacturer_url(@manufacturer)
  end

  test "should not create manufacturer with duplicate name" do
    assert_no_difference("Manufacturer.count") do
      post manufacturers_url, params: { manufacturer: { name: @manufacturer.name, vendor_id: @manufacturer.vendor_id } }
    end
  end
end
