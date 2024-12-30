# frozen_string_literal: true

class AddUniversalToVendors < ActiveRecord::Migration[7.1]
  def change
    add_column :vendors, :universal, :boolean
  end
end
