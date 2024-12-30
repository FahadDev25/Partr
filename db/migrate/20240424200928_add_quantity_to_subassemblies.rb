# frozen_string_literal: true

class AddQuantityToSubassemblies < ActiveRecord::Migration[7.1]
  def change
    add_column :subassemblies, :quantity, :integer
  end
end
