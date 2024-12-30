# frozen_string_literal: true

class CreateShipments < ActiveRecord::Migration[7.0]
  def change
    create_table :shipments do |t|
      t.text :from
      t.text :shipping_number
      t.date :date_received
      t.text :notes
      t.references :job, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
