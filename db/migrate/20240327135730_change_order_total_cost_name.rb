# frozen_string_literal: true

class ChangeOrderTotalCostName < ActiveRecord::Migration[7.1]
  def self.up
    rename_column :orders, :total_cost, :parts_cost
  end

  def self.down
    rename_column :orders,  :parts_cost, :total_cost
  end
end
