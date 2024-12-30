# frozen_string_literal: true

class CreatePartsReceived < ActiveRecord::Migration[7.0]
  def change
    create_table :parts_received do |t|
      t.belongs_to :shipment, null: false, foreign_key: true
      t.references :component, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
