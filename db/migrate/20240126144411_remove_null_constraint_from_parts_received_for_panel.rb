# frozen_string_literal: true

class RemoveNullConstraintFromPartsReceivedForPanel < ActiveRecord::Migration[7.0]
  def up
    change_column_null :parts_received, :panel_id, true
  end

  def down
    change_column_null :parts_received, :panel_id, false
  end
end
