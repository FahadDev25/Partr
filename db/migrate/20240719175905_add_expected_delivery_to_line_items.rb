# frozen_string_literal: true

class AddExpectedDeliveryToLineItems < ActiveRecord::Migration[7.1]
  def change
    add_column :line_items, :expected_delivery, :date
  end
end
