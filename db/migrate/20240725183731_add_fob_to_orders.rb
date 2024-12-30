# frozen_string_literal: true

class AddFobToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :fob, :string
  end
end
