# frozen_string_literal: true

class CreateComponents < ActiveRecord::Migration[7.0]
  def change
    create_table :components do |t|
      t.references :part, null: false, foreign_key: true
      t.references :panel, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
