# frozen_string_literal: true

class AddEnableManualLineItemsToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :enable_manual_line_items, :boolean, default: false
  end
end
