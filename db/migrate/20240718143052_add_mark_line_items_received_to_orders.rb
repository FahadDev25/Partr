# frozen_string_literal: true

class AddMarkLineItemsReceivedToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :mark_line_items_received, :boolean
  end
end
