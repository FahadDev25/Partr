# frozen_string_literal: true

require "test_helper"

class ShipmentMailerTest < ActionMailer::TestCase
  test "orderer_notify" do
    shipment = shipments(:button_shipment)
    mail = ShipmentMailer.orderer_notify(shipment)
    assert_equal "Shipment Received for Order: #{shipment.order.name}", mail.subject
    assert_equal ["admin@bio-next.net"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match (/#{shipment.from}/), mail.text_part.encoded
    assert_match (/#{shipment.shipping_number}/), mail.text_part.encoded
    assert_match (/#{shipment.from}/), mail.html_part.encoded
    assert_match (/#{shipment.shipping_number}/), mail.html_part.encoded
  end
end
