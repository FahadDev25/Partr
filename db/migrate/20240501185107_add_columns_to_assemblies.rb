# frozen_string_literal: true

class AddColumnsToAssemblies < ActiveRecord::Migration[7.1]
  def change
    add_column :assemblies, :notes, :text
    add_reference :assemblies, :customer, null: true, foreign_key: true
  end
end
