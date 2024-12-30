# frozen_string_literal: true

class AddColumnsToParts < ActiveRecord::Migration[7.0]
  def change
    add_column :parts, :meco_part_number, :text
    add_column :parts, :ul_file_number, :text
    add_column :parts, :ul_ccn, :text
  end
end
