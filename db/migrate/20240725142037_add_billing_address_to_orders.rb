# frozen_string_literal: true

class AddBillingAddressToOrders < ActiveRecord::Migration[7.1]
  def change
    add_reference :orders, :billing_address, null: true, foreign_key: { to_table: :addresses }
  end
end
