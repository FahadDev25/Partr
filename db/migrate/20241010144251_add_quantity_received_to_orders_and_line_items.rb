# frozen_string_literal: true

class AddQuantityReceivedToOrdersAndLineItems < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :quantity_received, :decimal
    add_column :orders, :total_quantity, :decimal
    add_column :orders, :received, :boolean
    add_column :line_items, :quantity_received, :decimal
    add_column :line_items, :received, :boolean
    add_column :line_items, :last_received_date, :date

    LineItem.all.each do |line_item|
      line_item.received_parts.each { |part_received| part_received.update_column(:line_item_id, line_item.id) }
      line_item.update_columns(
        quantity_received: line_item.parts_received.sum(&:quantity),
        last_received_date: line_item.parts_received.order(:date_received).last&.date_received
      )
      line_item.update_column :received, line_item.quantity_received >= line_item.quantity
    end

    Order.all.each do |order|
      order.update_columns(
        quantity_received: order.parts_received.sum(&:quantity),
        total_quantity: order.line_items.sum(&:quantity)
      )
      order.update_column :received, order.all_received
    end
  end
end
