# frozen_string_literal: true

class ReplaceVendorAddressWithReference < ActiveRecord::Migration[7.1]
  def up
    add_reference :vendors, :address, null: true, foreign_key: true
    Vendor.all.each do |vendor|
      next unless vendor.address.present? || vendor.address2.present? || vendor.city.present? || vendor.state.present? || vendor.zip_code.present?
      address = Address.create(
          address_1: vendor.address,
          address_2: vendor.address2,
          city: vendor.city,
          state: vendor.state,
          zip_code: vendor.zip_code,
          organization_id: vendor.organization_id
        )
      vendor.address_id = address.id
      vendor.save!
    end
    remove_column :vendors, :address
    remove_column :vendors, :address2
    remove_column :vendors, :city
    remove_column :vendors, :state
    remove_column :vendors, :zip_code
  end

  def down
    add_column :vendors, :address, :string
    add_column :vendors, :address2, :string
    add_column :vendors, :city, :string
    add_column :vendors, :state, :string
    add_column :vendors, :zip_code, :string
    Vendor.all.each do |vendor|
      next unless vendor.vendor_address.present?
      vendor.address = vendor.vendor_address.address_1
      vendor.address2 = vendor.vendor_address.address_2
      vendor.city = vendor.vendor_address.city
      vendor.state = vendor.vendor_address.state
      vendor.zip_code = vendor.vendor_address.zip_code
      vendor.save!
    end
    remove_reference :vendors, :address
  end
end
