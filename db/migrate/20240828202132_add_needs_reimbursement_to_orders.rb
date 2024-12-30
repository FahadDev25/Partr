# frozen_string_literal: true

class AddNeedsReimbursementToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :needs_reimbursement, :boolean, default: false
  end
end
