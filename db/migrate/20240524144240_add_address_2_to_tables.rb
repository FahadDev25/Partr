# frozen_string_literal: true

class AddAddress2ToTables < ActiveRecord::Migration[7.1]
  def change
    add_column :vendors, :address2, :text
    add_column :customers, :address2, :text
    add_column :organizations, :address2, :text
    add_column :teams, :address2, :text
  end
end
