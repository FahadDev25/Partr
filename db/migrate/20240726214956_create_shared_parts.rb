# frozen_string_literal: true

class CreateSharedParts < ActiveRecord::Migration[7.1]
  def change
    create_table :shared_parts do |t|
      t.references :part, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
