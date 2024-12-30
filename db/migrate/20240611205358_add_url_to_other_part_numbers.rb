# frozen_string_literal: true

class AddUrlToOtherPartNumbers < ActiveRecord::Migration[7.1]
  def change
    add_column :other_part_numbers, :url, :string
  end
end
