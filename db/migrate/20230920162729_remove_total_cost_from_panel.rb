# frozen_string_literal: true

class RemoveTotalCostFromPanel < ActiveRecord::Migration[7.0]
  def change
    remove_column :panels, :total_cost
  end
end
