# frozen_string_literal: true

class RemoveNullConstraintForOrderJobFromShipment < ActiveRecord::Migration[7.0]
  def up
    change_column_null :shipments, :order_id, true
    change_column_null :shipments, :job_id, true
  end

  def down
    change_column_null :shipments, :order_id, false
    change_column_null :shipments, :job_id, false
  end
end
