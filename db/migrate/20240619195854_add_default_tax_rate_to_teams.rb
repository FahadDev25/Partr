# frozen_string_literal: true

class AddDefaultTaxRateToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :default_tax_rate, :decimal, precision: 5, scale: 4
  end
end
