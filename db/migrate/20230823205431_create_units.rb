# frozen_string_literal: true

class CreateUnits < ActiveRecord::Migration[7.0]
  def change
    create_table :units do |t|
      t.belongs_to :job, null: false, foreign_key: true
      t.references :panel, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
