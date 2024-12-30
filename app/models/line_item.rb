# frozen_string_literal: true

class LineItem < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :order
  belongs_to :part, optional: true
  belongs_to :assembly, optional: true
  has_many :parts_received

  validates :part_id, presence: true, unless: :manual
  validates :description, :cost_per_unit, presence: true, if: :manual
  validates :quantity, numericality: { greater_than: 0 }
  validates :part_id, uniqueness: { scope: [:order, :assembly, :id_sequence], allow_blank: true }
  validates :discount, numericality: { in: 0..1, message: "must be between 0 and 1" }
  validates :cost_per_unit, numericality: { greater_than_or_equal_to: 0 }

  after_create :mark_received
  after_save :update_order_quantity
  before_destroy :destroy_parts_received_without_shipment
  after_destroy :update_order_quantity

  def part_and_assembly
    if assembly.present?
      "#{part.label} (#{sequence_label})"
    else
      part.label
    end
  end

  def received_parts
    order.parts_received.where(part_id:, assembly_id:, id_sequence:, description:)
  end

  def parts_received_ordered
    received = parts_received.sum(&:quantity)
    "#{received.to_s.sub(/\.0+$/, '')}/#{quantity.to_s.sub(/\.0+$/, '')}"
  end

  def select_label
    part.present? ? part_and_assembly : "#{sku} #{description}"
  end

  def set_cost_per_unit
    self.update cost_per_unit: part.cost_per_unit
  end

  def sequence_label
    label = ""
    Array(id_sequence).each do |seq|
      label += "#{Assembly.find(seq).name} > "
    end
    label += assembly.name
  end

  def id_and_sequence
    [assembly_id, id_sequence]
  end

  def update_order_quantity
    order.update total_quantity: order.line_items.sum(&:quantity)
    order.update received: order.all_received
  end

  private
    def mark_received
      return unless order.mark_line_items_received
      PartReceived.create!(job_id: order.job_id, line_item_id: id, assembly_id:, part_id:, quantity:, shipment_id: nil, id_sequence:, description:)
    end

    def destroy_parts_received_without_shipment
      parts_received.where(shipment: nil).destroy_all
    end
end
