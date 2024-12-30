# frozen_string_literal: true

class CreateParts < ActiveRecord::Migration[7.0]
  def change
    create_table :parts do |t|
      t.text :part_number
      t.text :description
      t.decimal :cost_per_unit, precision: 8, scale: 2
      t.integer :in_stock
      t.text :notes

      t.timestamps
    end
  end
end
