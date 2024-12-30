# frozen_string_literal: true

class AddAddressFieldsToOrders < ActiveRecord::Migration[7.1]
  def up
    add_column :orders, :address_1, :string
    add_column :orders, :address_2, :string
    add_column :orders, :city, :string
    add_column :orders, :state, :string
    add_column :orders, :zip_code, :string

    Order.all.each do |order|
      order.address_1 = order.team.address
      order.address_2 = order.team.address2
      order.city = order.team.city
      order.state = order.team.state
      order.zip_code = order.team.zip_code
      order.save!
    end
  end

  def down
    remove_column :orders, :address_1
    remove_column :orders, :address_2
    remove_column :orders, :city
    remove_column :orders, :state
    remove_column :orders, :zip_code
  end
end
