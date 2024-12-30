# frozen_string_literal: true

class AddAddressFieldsToJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :jobs, :address_1, :string
    add_column :jobs, :address_2, :string
    add_column :jobs, :city, :string
    add_column :jobs, :state, :string
    add_column :jobs, :zip_code, :string
  end
end
