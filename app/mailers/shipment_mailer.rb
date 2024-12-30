# frozen_string_literal: true

class ShipmentMailer < ApplicationMailer
  helper :mail

  def orderer_notify(shipment)
    @shipment = shipment
    @order = @shipment.order
    @user = @order.user

    mail to: @user.email, subject: "Shipment Received for Order: #{@order.name}"
  end
end
