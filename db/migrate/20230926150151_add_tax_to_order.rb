# frozen_string_literal: true

class AddTaxToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :tax_rate, :decimal, precision: 8, scale: 2
  end
end
