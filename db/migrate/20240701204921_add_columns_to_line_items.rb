# frozen_string_literal: true

class AddColumnsToLineItems < ActiveRecord::Migration[7.1]
  def change
    add_column :line_items, :manual, :boolean, default: false
    add_column :line_items, :description, :text
  end
end
