# frozen_string_literal: true

class AddVendorToManufacturer < ActiveRecord::Migration[7.0]
  def change
    add_reference :manufacturers, :vendor, null: true, foreign_key: true
  end
end
