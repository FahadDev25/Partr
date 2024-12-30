# frozen_string_literal: true

class AddAddressToOrganization < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :address, :string
    add_column :organizations, :city, :string
    add_column :organizations, :state, :string
    add_column :organizations, :zip_code, :string
    add_column :organizations, :phone_number, :string
  end
end
