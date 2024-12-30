# frozen_string_literal: true

class AddReceivedToAdditionalParts < ActiveRecord::Migration[7.0]
  def change
    add_column :additional_parts, :received, :boolean, default: false
  end
end
