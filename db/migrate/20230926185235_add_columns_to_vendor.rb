# frozen_string_literal: true

class AddColumnsToVendor < ActiveRecord::Migration[7.0]
  def change
    add_column :vendors, :address, :text
    add_column :vendors, :city, :text
    add_column :vendors, :state, :text, limit: 2
    add_column :vendors, :zip_code, :text
    add_column :vendors, :phone_number, :bigint
    add_column :vendors, :representative, :text
  end
end
