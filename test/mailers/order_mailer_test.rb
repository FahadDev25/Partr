# frozen_string_literal: true

require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  test "parts_not_received" do
    mail = OrderMailer.parts_not_received(orders(:claws_order), orders(:claws_order).parts_not_received, "test@msi-group.net")
    assert_equal "Parts not received", mail.subject
    assert_equal ["test@msi-group.net"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match (/lev123/), mail.text_part.encoded
    assert_match (/0\/2/), mail.text_part.encoded
    assert_match (/lev123/), mail.html_part.encoded
    assert_match (/0\/2/), mail.html_part.encoded
  end

  test "reimbursement_notify" do
    order = orders(:button_order)
    user = users(:johnsmith)
    teams(:trapsmiths).update(send_accounting_notifications_to: [user.id])
    mail = OrderMailer.reimbursement_notify(order)
    assert_equal "Reimbursement Needed for Order", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match (/#{order.po_number}/), mail.text_part.encoded
    assert_match (/#{order.user.full_name}/), mail.text_part.encoded
  end
end
