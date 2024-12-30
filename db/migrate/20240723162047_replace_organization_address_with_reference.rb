# frozen_string_literal: true

class ReplaceOrganizationAddressWithReference < ActiveRecord::Migration[7.1]
  def up
    add_reference :organizations, :address, null: true, foreign_key: true
    Organization.all.each do |org|
      next unless org.address.present? || org.address2.present? || org.city.present? || org.state.present? || org.zip_code.present?
      address = Address.create(
        address_1: org.address,
        address_2: org.address2,
        city: org.city,
        state: org.state,
        zip_code: org.zip_code,
        organization_id: org.id
      )
      org.address_id = address.id
      org.save!
    end
    remove_column :organizations, :address
    remove_column :organizations, :address2
    remove_column :organizations, :city
    remove_column :organizations, :state
    remove_column :organizations, :zip_code
  end

  def down
    add_column :organizations, :address, :string
    add_column :organizations, :address2, :string
    add_column :organizations, :city, :string
    add_column :organizations, :state, :string
    add_column :organizations, :zip_code, :string
    Organization.all.each do |org|
      next unless org.hq_address.present?
      org.address = org.hq_address.address_1
      org.address2 = org.hq_address.address_2
      org.city = org.hq_address.city
      org.state = org.hq_address.state
      org.zip_code = org.hq_address.zip_code
      org.save!
    end
    remove_reference :organizations, :address
  end
end
