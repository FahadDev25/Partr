# frozen_string_literal: true

class ChangePartNumberName < ActiveRecord::Migration[7.1]
  def self.up
    rename_column :parts, :part_number, :mfg_part_number
  end

  def self.down
    rename_column :parts, :mfg_part_number, :part_number
  end
end
