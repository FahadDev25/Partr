# frozen_string_literal: true

require "test_helper"

class CheckOrderPartsReceivedJobTest < ActiveJob::TestCase
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  setup do
    @order = orders(:claws_order)
    @user = users(:admin)
    sign_in @user
  end

  test "should send email for missing order parts" do
    CheckOrderPartsReceivedJob.perform_now(@order, @user.email)
    assert_enqueued_emails 1
  end
end
