# frozen_string_literal: true

class RemoveExportOptionsFromOrders < ActiveRecord::Migration[7.1]
  def change
    remove_column :orders, :include_job_name, :boolean
    remove_column :orders, :include_job_number, :boolean
  end
end
