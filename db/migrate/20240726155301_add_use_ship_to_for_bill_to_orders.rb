# frozen_string_literal: true

class AddUseShipToForBillToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :use_ship_for_bill, :boolean
  end
end
