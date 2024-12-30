# frozen_string_literal: true

class AddUrlToParts < ActiveRecord::Migration[7.1]
  def change
    add_column :parts, :url, :string
  end
end
