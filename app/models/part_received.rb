# frozen_string_literal: true

class PartReceived < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :shipment, optional: true
  belongs_to :assembly, optional: true
  belongs_to :part, optional: true
  belongs_to :job, optional: true
  belongs_to :line_item, optional: true
  belongs_to :user, optional: true

  validates :part_id, presence: true, unless: :description
  validates :description, presence: true, unless: :part_id
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  after_save :update_line_item_and_order
  after_destroy :update_line_item_and_order

  def assembly_name
    name = ""
    Array(id_sequence).each do |id|
      name += "#{Assembly.find(id).name} > "
    end
    name += assembly.name
  end

  def id_and_sequence
    [assembly_id, id_sequence]
  end

  def update_line_item_and_order
    return unless line_item.present?
    line_item.update(
      quantity_received: line_item.parts_received.sum(&:quantity),
      last_received_date: line_item.parts_received.order(:date_received).last&.date_received
    )
    line_item.update received: line_item.quantity_received >= line_item.quantity

    line_item.order.update(
      quantity_received: line_item.order.parts_received.sum(&:quantity),
      total_quantity: line_item.order.line_items.sum(&:quantity)
    )
    line_item.order.update received: line_item.order.all_received
  end
end
