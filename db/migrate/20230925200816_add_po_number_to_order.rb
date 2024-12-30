# frozen_string_literal: true

class AddPoNumberToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :po_number, :text
  end
end
