# frozen_string_literal: true

class AddDiscountToLineItem < ActiveRecord::Migration[7.0]
  def change
    add_column :line_items, :discount, :decimal, precision: 3, scale: 2
  end
end
