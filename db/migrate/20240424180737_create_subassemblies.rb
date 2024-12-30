# frozen_string_literal: true

class CreateSubassemblies < ActiveRecord::Migration[7.1]
  def change
    create_table :subassemblies do |t|
      t.references :parent_assembly, null: false, foreign_key: { to_table: :assemblies }
      t.references :child_assembly, null: false, foreign_key: { to_table: :assemblies }

      t.timestamps
    end
  end
end
