# frozen_string_literal: true

class CreateManufacturers < ActiveRecord::Migration[7.0]
  def change
    create_table :manufacturers do |t|
      t.text :name

      t.timestamps
    end
  end
end
