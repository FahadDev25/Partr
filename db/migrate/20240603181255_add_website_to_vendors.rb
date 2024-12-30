# frozen_string_literal: true

class AddWebsiteToVendors < ActiveRecord::Migration[7.1]
  def change
    add_column :vendors, :website, :text
  end
end
