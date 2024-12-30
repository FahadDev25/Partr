# frozen_string_literal: true

require "test_helper"

class UnitCheckPartsReceivedJobTest < ActiveJob::TestCase
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  setup do
    @unit = units(:failsafe)
    @unit2 = units(:only_subassembly)
    @user = users(:admin)
    sign_in @user
  end

  test "should send email for part mismatch" do
    UnitCheckPartsReceivedJob.perform_now(@unit, @user.email)
    assert_enqueued_emails 1
  end

  test "should send email for subassembly part mismatch" do
    PartReceived.create(
      assembly_id: @unit2.assembly_id,
      part_id: parts(:lever).id,
      quantity: 2,
      shipment_id: nil,
      id_sequence: [assemblies(:just_subassembly).id]
    )
    UnitCheckPartsReceivedJob.perform_now(@unit, @user.email)
    assert_enqueued_emails 1
  end
end
