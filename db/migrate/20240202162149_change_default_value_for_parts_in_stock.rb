# frozen_string_literal: true

class ChangeDefaultValueForPartsInStock < ActiveRecord::Migration[7.0]
  def up
    change_column_default :parts, :in_stock, from: nil, to: 0
    Part.connection.execute("UPDATE parts SET in_stock = 0 WHERE in_stock IS NULL")
  end
  def down
    change_column_default :parts, :in_stock, from: 0, to: nil
  end
end
