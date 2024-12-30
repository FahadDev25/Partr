# frozen_string_literal: true

class AddReceivedToUnit < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :received, :boolean, default: false
  end
end
