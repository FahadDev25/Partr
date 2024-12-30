# frozen_string_literal: true

require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
  setup do
    @user = users(:admin)
    sign_in @user
    ActsAsTenant.current_tenant = organizations(:artificers)
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!
  end
  test "should import from partr csv" do
    assert_difference("Customer.count", 20) do
      output = Customer.csv_import("test/fixtures/files/customers_2024-05-24.csv", @team)
      assert_equal "Customers Read: 21 | Customers Modified: 1 | Customers Added: 20", output
    end
  end
end
