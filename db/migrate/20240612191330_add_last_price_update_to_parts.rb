# frozen_string_literal: true

class AddLastPriceUpdateToParts < ActiveRecord::Migration[7.1]
  def change
    add_column :parts, :last_price_update, :date
  end
end
