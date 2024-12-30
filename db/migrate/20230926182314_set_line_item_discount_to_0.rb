# frozen_string_literal: true

class SetLineItemDiscountTo0 < ActiveRecord::Migration[7.0]
  def change
    LineItem.update_all(discount: 0.00)
  end
end
