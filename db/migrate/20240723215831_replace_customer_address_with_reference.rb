# frozen_string_literal: true

class ReplaceCustomerAddressWithReference < ActiveRecord::Migration[7.1]
  def up
    add_reference :customers, :address, null: true, foreign_key: true
    Customer.all.each do |customer|
      next unless customer.address.present? || customer.address2.present? || customer.city.present? || customer.state.present? || customer.zip_code.present?
      address = Address.create(
          address_1: customer.address,
          address_2: customer.address2,
          city: customer.city,
          state: customer.state,
          zip_code: customer.zip_code,
          organization_id: customer.organization_id
        )
      customer.address_id = address.id
      customer.save!
    end
    remove_column :customers, :address
    remove_column :customers, :address2
    remove_column :customers, :city
    remove_column :customers, :state
    remove_column :customers, :zip_code
  end

  def down
    add_column :customers, :address, :string
    add_column :customers, :address2, :string
    add_column :customers, :city, :string
    add_column :customers, :state, :string
    add_column :customers, :zip_code, :string
    Customer.all.each do |customer|
      next unless customer.customer_address.present?
      customer.address = customer.customer_address.address_1
      customer.address2 = customer.customer_address.address_2
      customer.city = customer.customer_address.city
      customer.state = customer.customer_address.state
      customer.zip_code = customer.customer_address.zip_code
      customer.save!
    end
    remove_reference :customers, :address
  end
end
