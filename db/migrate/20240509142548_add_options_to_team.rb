# frozen_string_literal: true

class AddOptionsToTeam < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :default_unit, :string
    add_column :teams, :assembly_label, :string
  end
end
