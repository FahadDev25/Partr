# frozen_string_literal: true

class AddAddressToTeam < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :use_org_addr, :boolean
    add_column :teams, :use_org_phone, :boolean
    add_column :teams, :address, :string
    add_column :teams, :city, :string
    add_column :teams, :state, :string
    add_column :teams, :zip_code, :string
    add_column :teams, :phone_number, :string
  end
end
