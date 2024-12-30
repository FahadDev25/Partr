# frozen_string_literal: true

class ChangeLineItemPartIdNotNullTrue < ActiveRecord::Migration[7.1]
  def change
    change_column :line_items, :part_id, :integer, null: true
  end
end
