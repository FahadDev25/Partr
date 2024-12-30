# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/shipment_mailer
class ShipmentMailerPreview < ActionMailer::Preview
  def orderer_notify
    ShipmentMailer.orderer_notify(Shipment.first)
  end
end
