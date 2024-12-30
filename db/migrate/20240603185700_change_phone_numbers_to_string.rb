# frozen_string_literal: true

class ChangePhoneNumbersToString < ActiveRecord::Migration[7.1]
  def change
    change_column :customers, :phone_number, :string
    change_column :organizations, :phone_number, :string
    change_column :teams, :phone_number, :string
    change_column :customers, :phone_number, :string
    change_column :vendors, :phone_number, :string
  end
end
