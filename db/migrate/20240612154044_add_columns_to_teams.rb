# frozen_string_literal: true

class AddColumnsToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :show_cert_number_1, :boolean
    add_column :teams, :show_cert_number_2, :boolean
    add_column :teams, :cert_number_1_name, :string
    add_column :teams, :cert_number_2_name, :string
  end
end
