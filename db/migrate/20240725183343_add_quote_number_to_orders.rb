# frozen_string_literal: true

class AddQuoteNumberToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :quote_number, :string
  end
end
