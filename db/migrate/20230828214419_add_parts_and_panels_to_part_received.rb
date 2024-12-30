# frozen_string_literal: true

class AddPartsAndPanelsToPartReceived < ActiveRecord::Migration[7.0]
  def change
    add_reference :parts_received, :part, null: false, foreign_key: true
    add_reference :parts_received, :panel, null: false, foreign_key: true
  end
end
