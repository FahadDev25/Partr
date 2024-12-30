# frozen_string_literal: true

class AddPrimaryToOtherPartNumbers < ActiveRecord::Migration[7.1]
  def up
    add_column :other_part_numbers, :primary, :boolean, default: false
  end

  def down
    remove_column :other_part_numbers, :primary
  end
end
