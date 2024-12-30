# frozen_string_literal: true

class AdditionalPartsCheckPartsReceivedJob < ApplicationJob
  queue_as :default

  def perform(additional_part, mail_to)
    number_received = additional_part.parts_received.sum(&:quantity)
    additional_part.received = number_received >= additional_part.quantity
    additional_part.save!

    AdditionalPartsMailer.part_quantity_mismatch(additional_part, "#{number_received}/#{additional_part.quantity}", mail_to).deliver_later if number_received > additional_part.quantity
  end
end
