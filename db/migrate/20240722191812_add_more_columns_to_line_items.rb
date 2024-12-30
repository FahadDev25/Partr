# frozen_string_literal: true

class AddMoreColumnsToLineItems < ActiveRecord::Migration[7.1]
  def change
    add_column :line_items, :status_location, :text
    add_column :line_items, :om_warranty, :text
    add_column :line_items, :notes, :text
  end
end
