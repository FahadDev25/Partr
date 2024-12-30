# frozen_string_literal: true

class CreatePriceChanges < ActiveRecord::Migration[7.1]
  def change
    create_table :price_changes do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.date :date_changed
      t.decimal :cost_per_unit, precision: 10, scale: 4

      t.timestamps
    end
  end
end
