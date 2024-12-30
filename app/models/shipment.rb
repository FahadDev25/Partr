# frozen_string_literal: true

class Shipment < ApplicationRecord
  include TeamSharing

  acts_as_tenant :organization

  belongs_to :team
  belongs_to :job, optional: true
  belongs_to :order, optional: true
  belongs_to :user, optional: true

  has_many :parts_received
  has_many :comments, as: :commentable

  has_many_attached :packing_slips do |ps|
    ps.variant :thumb, resize_to_limit: [100, 100]
  end

  validates :date_received, presence: true
  validates :packing_slips, blob: { content_type: ["image/png", "image/jpg", "image/jpeg", "application/pdf"] }

  def label
    "#{shipping_number} #{from} #{date_received}"
  end

  def attach_packing_slips=(slips)
    slips.each_with_index do |slip, i|
      next unless slip.present? && (["image/png", "image/jpg", "image/jpeg"].include? slip.content_type)
      path = slip.tempfile.path
      image = ImageProcessing::Vips.source(path)
      result = image.resize_to_limit!(1000, 1000)
      slips[i].tempfile = result
    end
    packing_slips.attach(slips)
  end

  def line_item_select_list(action)
    list = { "none" => nil }
    if action == "new"
      return list unless unreceived_line_items.any?
      list.merge! unreceived_line_items.order(:sku).map { |line_item| { (line_item.part ? line_item.part_and_assembly : "#{line_item.sku} #{line_item.description}") => line_item.id } }.reduce(:merge)
    else
      list.merge! order.line_items.order(:sku).map { |line_item| { (line_item.part ? line_item.part_and_assembly : "#{line_item.sku} #{line_item.description}") => line_item.id } }.reduce(:merge)
    end
  end

  def unreceived_line_items
    order.line_items.where.not(id: parts_received.pluck(:line_item_id))
  end
end
