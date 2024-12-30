# frozen_string_literal: true

class AddUnitsToParts < ActiveRecord::Migration[7.0]
  def change
    add_column :parts, :unit, :string
  end
end
