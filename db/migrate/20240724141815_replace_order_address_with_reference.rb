# frozen_string_literal: true

class ReplaceOrderAddressWithReference < ActiveRecord::Migration[7.1]
  def up
    add_reference :orders, :address, null: true, foreign_key: true
    Order.all.each do |order|
      next unless order.address_1.present? || order.address_2.present? || order.city.present? || order.state.present? || order.zip_code.present?
      address = Address.create(
          address_1: order.address_1,
          address_2: order.address_2,
          city: order.city,
          state: order.state,
          zip_code: order.zip_code,
          organization_id: order.organization_id
        )
      order.address_id = address.id
      order.save!
    end
    remove_column :orders, :address_1
    remove_column :orders, :address_2
    remove_column :orders, :city
    remove_column :orders, :state
    remove_column :orders, :zip_code
  end

  def down
    add_column :orders, :address_1, :string
    add_column :orders, :address_2, :string
    add_column :orders, :city, :string
    add_column :orders, :state, :string
    add_column :orders, :zip_code, :string
    Order.all.each do |order|
      next unless order.ship_to.present?
      order.address_1 = order.ship_to.address_1
      order.address_2 = order.ship_to.address_2
      order.city = order.ship_to.city
      order.state = order.ship_to.state
      order.zip_code = order.ship_to.zip_code
      order.save!
    end
    remove_reference :orders, :address
  end
end
