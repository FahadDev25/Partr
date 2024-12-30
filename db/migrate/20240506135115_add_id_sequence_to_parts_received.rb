# frozen_string_literal: true

class AddIdSequenceToPartsReceived < ActiveRecord::Migration[7.1]
  def change
    add_column :parts_received, :id_sequence, :integer, array: true, default: nil
  end
end
