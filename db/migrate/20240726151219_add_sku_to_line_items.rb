# frozen_string_literal: true

class AddSkuToLineItems < ActiveRecord::Migration[7.1]
  def change
    add_column :line_items, :sku, :string
  end
end
