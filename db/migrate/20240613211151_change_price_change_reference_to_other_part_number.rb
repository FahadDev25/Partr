# frozen_string_literal: true

class ChangePriceChangeReferenceToOtherPartNumber < ActiveRecord::Migration[7.1]
  def change
    remove_reference :price_changes, :part
    add_reference :price_changes, :other_part_number, null: false, foreign_key: true
  end
end
