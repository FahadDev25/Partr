# frozen_string_literal: true

require "test_helper"

class TeamRoleTest < ActiveSupport::TestCase
  test "role with all order/job/shipment should have access to all oders/jobs/shipments" do
    @team = teams(:artificer_accounting)
    @organization = organizations(:artificers)

    assert_equal @team.jobs, @organization.jobs
    assert_equal @team.orders, @organization.orders
    assert_equal @team.shipments, @organization.shipments
  end
end
