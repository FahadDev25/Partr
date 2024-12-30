# frozen_string_literal: true

class CreateTeamRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :team_roles do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :role_name
      t.boolean :create_destroy_job
      t.boolean :all_job
      t.boolean :all_order
      t.boolean :all_shipment

      t.timestamps
    end
  end
end
