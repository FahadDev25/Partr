# frozen_string_literal: true

class AddAssemblyAndIdSequenceToLineItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :line_items, :assembly, null: true, foreign_key: true, default: nil
    add_column :line_items, :id_sequence, :integer, array: true, default: nil
  end
end
