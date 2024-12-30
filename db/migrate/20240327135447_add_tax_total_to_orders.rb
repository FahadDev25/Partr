# frozen_string_literal: true

class AddTaxTotalToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :tax_total, :decimal
  end
end
