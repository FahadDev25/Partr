# frozen_string_literal: true

class AddTotalCostToOrder < ActiveRecord::Migration[7.1]
  def up
    add_column :orders, :total_cost, :decimal
    Order.all.each { |order| order.update_cost }
  end
  def down
    remove_column :orders, :total_cost
  end
end
