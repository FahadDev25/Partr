# frozen_string_literal: true

class CheckOrderPartsReceivedJob < ApplicationJob
  queue_as :default

  def perform(order, mail_to)
    not_received = order.parts_not_received

    OrderMailer.parts_not_received(order, not_received, mail_to).deliver_later if not_received.any?
  end
end
