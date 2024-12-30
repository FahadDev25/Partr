# frozen_string_literal: true

class CreateAdditionalParts < ActiveRecord::Migration[7.0]
  def change
    create_table :additional_parts do |t|
      t.references :job, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
