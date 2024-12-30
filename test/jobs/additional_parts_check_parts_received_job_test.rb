# frozen_string_literal: true

require "test_helper"

class AdditionalPartsCheckPartsReceivedJobTest < ActiveJob::TestCase
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper
  setup do
    @claws = additional_parts(:extra_claws)
    @button = parts(:big_red_button)
    @user = users(:admin)
    sign_in @user
  end
  test "should send email for part mismatch" do
    AdditionalPartsCheckPartsReceivedJob.perform_now(@claws, @user.email)
    assert_enqueued_emails 1
  end
end
