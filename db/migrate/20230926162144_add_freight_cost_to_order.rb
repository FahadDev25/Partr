# frozen_string_literal: true

class AddFreightCostToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :freight_cost, :decimal, precision: 8, scale: 2
  end
end
