# frozen_string_literal: true

require "test_helper"

class ManufacturerTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
  setup do
    @user = users(:admin)
    sign_in @user
    ActsAsTenant.current_tenant = organizations(:artificers)
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end
  test "should import from partr csv" do
    assert_difference("Manufacturer.count", 43) do
      output = Manufacturer.csv_import("test/fixtures/files/manufacturers_2024-05-23.csv", @team)
      assert_equal "Manufacturers Read: 43 | Manufacturers Added: 43 | Vendors Added: 16", output
    end
  end
end
