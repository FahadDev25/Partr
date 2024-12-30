# frozen_string_literal: true

class ChangeTaxRateInOrders < ActiveRecord::Migration[7.1]
  def up
    change_column :orders, :tax_rate, :decimal, precision: 5, scale: 4
  end

  def down
    change_column :orders, :tax_rate, :decimal, precision: 8, scale: 2
  end
end
