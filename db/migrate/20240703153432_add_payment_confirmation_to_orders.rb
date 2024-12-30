# frozen_string_literal: true

class AddPaymentConfirmationToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :payment_confirmation, :string
  end
end
