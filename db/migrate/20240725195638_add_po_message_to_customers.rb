# frozen_string_literal: true

class AddPoMessageToCustomers < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :po_message, :text
  end
end
