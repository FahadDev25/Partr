# frozen_string_literal: true

class AddColumnsForUi < ActiveRecord::Migration[7.1]
  def change
    add_reference :shipments, :user, null: true, foreign_key: true
    add_column :shipments, :status, :string

    add_reference :parts_received, :user, null: true, foreign_key: true
    add_column :parts_received, :status, :string
    add_column :parts_received, :date_received, :date
  end
end
