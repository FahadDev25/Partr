# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.decimal :total_cost
      t.date :order_date
      t.belongs_to :vendor, null: false, foreign_key: true
      t.references :job, null: true, foreign_key: true

      t.timestamps
    end
  end
end
