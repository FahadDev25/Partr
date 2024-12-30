# frozen_string_literal: true

class AddTotalsColumnsToAssemblies < ActiveRecord::Migration[7.1]
  def up
    add_column :assemblies, :total_cost, :decimal
    add_column :assemblies, :total_components, :integer
    add_column :assemblies, :total_quantity, :integer

    Assembly.all.each do |assembly|
      assembly.update_totals
    end
  end

  def down
    remove_column :assemblies, :total_cost
    remove_column :assemblies, :total_components
    remove_column :assemblies, :total_quantity
  end
end
