# frozen_string_literal: true

class CreatePanels < ActiveRecord::Migration[7.0]
  def change
    create_table :panels do |t|
      t.text :name
      t.decimal :total_cost, precision: 8, scale: 2

      t.timestamps
    end
  end
end
