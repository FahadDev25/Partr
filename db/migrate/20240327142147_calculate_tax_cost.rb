# frozen_string_literal: true

class CalculateTaxCost < ActiveRecord::Migration[7.1]
  def up
    Order.update_all("tax_total=parts_cost*(tax_rate)")
  end

  def down
    Order.update_all("tax_total=0")
  end
end
