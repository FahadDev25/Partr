# frozen_string_literal: true

class AdditionalPart < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :job
  belongs_to :part

  validates :quantity, numericality: { greater_than: 0 }

  def parts_ordered
    LineItem.where(assembly_id: nil, part_id:).joins(:order).where("orders.order_date <= current_date AND orders.job_id = ?", job_id)
  end

  def parts_received
    PartReceived.where(assembly_id: nil, part_id:, job_id:)
  end

  def parts_ordered_required
    ordered = parts_ordered.sum(&:quantity)
    "#{ordered.to_s.sub(/\.0+$/, '')}/#{quantity.to_s.sub(/\.0+$/, '')}" + (ordered >= quantity ? " \u2714" : "")
  end

  def parts_received_required
    received = parts_received.sum(&:quantity)
    "#{received.to_s.sub(/\.0+$/, '')}/#{quantity.to_s.sub(/\.0+$/, '')}" + (received >= quantity ? " \u2714" : "")
  end

  def quantity_needed
    received = parts_received.sum(&:quantity)
    quantity - received
  end
end
