# frozen_string_literal: true

class CreateOtherPartNumbers < ActiveRecord::Migration[7.1]
  def change
    create_table :other_part_numbers do |t|
      t.string :opn_type
      t.string :company
      t.string :part_number
      t.references :part, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
