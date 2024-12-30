# frozen_string_literal: true

class AddOptionsToOrder < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :include_job_name, :boolean, default: true
    add_column :orders, :include_job_number, :boolean, default: true
  end
end
