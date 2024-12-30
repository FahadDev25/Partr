# frozen_string_literal: true

class AddCostPerUnitToLineItems < ActiveRecord::Migration[7.1]
  def change
    add_column :line_items, :cost_per_unit, :decimal, precision: 10, scale: 4
  end
end
