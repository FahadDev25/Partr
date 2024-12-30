# frozen_string_literal: true

class AddAddressAndPhoneToCustomer < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :address, :string
    add_column :customers, :city, :string
    add_column :customers, :state, :string
    add_column :customers, :zip_code, :string
    add_column :customers, :phone_number, :string
  end
end
