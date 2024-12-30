# frozen_string_literal: true

class AddIncludeInBomToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :include_in_bom, :boolean
  end
end
