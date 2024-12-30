# frozen_string_literal: true

class ChangeOrdersVendorColumnNullToTrue < ActiveRecord::Migration[7.0]
  def up
    change_column_null :orders, :vendor_id, true
  end

  def down
    change_column_null :orders, :vendor_id, false
  end
end
