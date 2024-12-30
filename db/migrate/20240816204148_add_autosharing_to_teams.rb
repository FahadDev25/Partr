# frozen_string_literal: true

class AddAutosharingToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :share_jobs_with, :string
    add_column :teams, :share_orders_with, :string
    add_column :teams, :share_shipments_with, :string
  end
end
