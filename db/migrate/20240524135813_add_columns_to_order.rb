# frozen_string_literal: true

class AddColumnsToOrder < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :date_paid, :date
    add_column :orders, :amount_paid, :decimal, precision: 8, scale: 2
  end
end
