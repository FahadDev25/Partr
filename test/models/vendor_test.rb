# frozen_string_literal: true

require "test_helper"

class VendorTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
  setup do
    @user = users(:admin)
    sign_in @user
    ActsAsTenant.current_tenant = organizations(:artificers)
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end
  test "should import from partr csv" do
    assert_difference("Vendor.count", 21) do
      output = Vendor.csv_import("test/fixtures/files/vendors_2024-05-24.csv", @team)
      assert_equal "Vendors Read: 21 | Vendors Added: 21", output
    end
  end
end
