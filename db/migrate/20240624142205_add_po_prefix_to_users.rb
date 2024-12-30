# frozen_string_literal: true

class AddPoPrefixToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :po_prefix, :string
  end
end
