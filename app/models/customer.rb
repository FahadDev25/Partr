# frozen_string_literal: true

class Customer < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :team
  belongs_to :customer_address, class_name: "Address", foreign_key: "address_id", optional: true
  has_many :jobs
  has_many :other_part_numbers, as: :company, dependent: :destroy

  accepts_nested_attributes_for :customer_address, reject_if: :all_blank

  validates :name, presence: true
  validates_uniqueness_to_tenant :name

  def self.csv_export(customers)
    CSV.generate do |csv|
      csv << ["Name", "Address 1", "Address 2", "City", "State", "Zip Code", "Phone Number"]
      customers.each do |customer|
        csv << [customer.name, customer.customer_address&.address_1, customer.customer_address&.address_2, customer.customer_address&.city,
                customer.customer_address&.state, customer.customer_address&.zip_code, customer.phone_number]
      end
    end
  end

  def self.csv_import(file, team)
    customers_read = 0
    customers_modified = 0
    customers_added = 0

    map = {
      "Name" => :name,
      "Address 1" => :address_1,
      "Address 2" => :address_2,
      "City" => :city,
      "State" => :state,
      "Zip Code" => :zip_code,
      "Phone Number" => :phone_number
    }

    CSV.foreach(file, headers: true) do |row|
      customers_read += 1
      data = { customer_address_attributes: {} }
      row.to_hash.each do |k, v|
        key = map[k]
        if ["Name", "Phone Number"].include? k
          data[key] = v
        else
          data[:customer_address_attributes][key] = v
        end
      end

      data[:team_id] = team.id
      data[:organization_id] = team.organization_id

      if customer = Customer.find_by(name: data[:name])
        customer.update(data)
        customers_modified += 1 if customer.previous_changes.length > 0
      else
        Customer.create!(data)
        customers_added += 1
      end
    end

    stats = ["Customers Read: #{customers_read}"]
    stats << "Customers Modified: #{customers_modified}" if customers_modified > 0
    stats << "Customers Added: #{customers_added}" if customers_added > 0
    stats.join(" | ")
  end
end
