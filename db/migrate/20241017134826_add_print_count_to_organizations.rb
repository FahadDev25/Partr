# frozen_string_literal: true

class AddPrintCountToOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :print_count, :integer, default: 0
  end
end
