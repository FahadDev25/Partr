# frozen_string_literal: true

class FractionalPennies < ActiveRecord::Migration[7.1]
  def up
    change_column :assemblies, :total_cost, :decimal, precision: 10, scale: 4
    change_column :jobs, :total_cost, :decimal, precision: 10, scale: 4
    change_column :orders, :total_cost, :decimal, precision: 10, scale: 4
    change_column :orders, :parts_cost, :decimal, precision: 10, scale: 4
    change_column :orders, :freight_cost, :decimal, precision: 10, scale: 4
    change_column :orders, :tax_total, :decimal, precision: 10, scale: 4
    change_column :parts, :cost_per_unit, :decimal, precision: 10, scale: 4
  end

  def down
    change_column :assemblies, :total_cost, :decimal, precision: 8, scale: 2
    change_column :jobs, :total_cost, :decimal, precision: 8, scale: 2
    change_column :orders, :total_cost, :decimal, precision: 8, scale: 2
    change_column :orders, :parts_cost, :decimal, precision: 8, scale: 2
    change_column :orders, :freight_cost, :decimal, precision: 8, scale: 2
    change_column :orders, :tax_total, :decimal, precision: 8, scale: 2
    change_column :parts, :cost_per_unit, :decimal, precision: 8, scale: 2
  end
end
