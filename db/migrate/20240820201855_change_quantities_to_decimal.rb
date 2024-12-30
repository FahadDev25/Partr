# frozen_string_literal: true

class ChangeQuantitiesToDecimal < ActiveRecord::Migration[7.1]
  def up
    change_column :additional_parts, :quantity, :decimal
    change_column :assemblies, :total_quantity, :decimal
    change_column :parts_received, :quantity, :decimal
    change_column :components, :quantity, :decimal
    change_column :line_items, :quantity, :decimal
    change_column :parts, :in_stock, :decimal
  end

  def down
    change_column :additional_parts, :quantity, :integer
    change_column :assemblies, :total_quantity, :integer
    change_column :parts_received, :quantity, :integer
    change_column :components, :quantity, :integer
    change_column :line_items, :quantity, :integer
    change_column :parts, :in_stock, :integer
  end
end
