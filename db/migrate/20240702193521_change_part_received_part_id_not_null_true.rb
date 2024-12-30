# frozen_string_literal: true

class ChangePartReceivedPartIdNotNullTrue < ActiveRecord::Migration[7.1]
  def change
    change_column :parts_received, :part_id, :integer, null: true
  end
end
