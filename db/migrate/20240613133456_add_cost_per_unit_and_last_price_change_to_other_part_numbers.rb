# frozen_string_literal: true

class AddCostPerUnitAndLastPriceChangeToOtherPartNumbers < ActiveRecord::Migration[7.1]
  def change
    add_column :other_part_numbers, :cost_per_unit, :decimal, precision: 10, scale: 4
    add_column :other_part_numbers, :last_price_update, :date
  end
end
