# frozen_string_literal: true

class AddJobToPartReceived < ActiveRecord::Migration[7.0]
  def up
    add_reference :parts_received, :job, null: true, foreign_key: true
    change_column_null :parts_received, :shipment_id, true
    PartReceived.connection.execute("UPDATE parts_received SET job_id = (SELECT job_id FROM shipments WHERE shipments.id = parts_received.shipment_id)")
  end
  def down
    remove_reference :parts_received, :job, null: false, foreign_key: true
    change_column_null :parts_received, :shipment_id, false
  end
end
