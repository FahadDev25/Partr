# frozen_string_literal: true

class AddNotesToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :notes, :text
  end
end
