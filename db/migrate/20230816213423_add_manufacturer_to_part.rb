# frozen_string_literal: true

class AddManufacturerToPart < ActiveRecord::Migration[7.0]
  def change
    add_reference :parts, :manufacturer, null: true, foreign_key: true
  end
end
