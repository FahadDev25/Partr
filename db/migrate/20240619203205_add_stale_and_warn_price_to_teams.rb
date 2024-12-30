# frozen_string_literal: true

class AddStaleAndWarnPriceToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :stale, :integer
    add_column :teams, :warn, :integer
  end
end
