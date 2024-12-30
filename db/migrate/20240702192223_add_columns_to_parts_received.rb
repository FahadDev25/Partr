# frozen_string_literal: true

class AddColumnsToPartsReceived < ActiveRecord::Migration[7.1]
  def change
    add_reference :parts_received, :line_item, null: true, foreign_key: true
    add_column :parts_received, :description, :text
  end
end
