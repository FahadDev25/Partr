# frozen_string_literal: true

class Vendor < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :team
  belongs_to :vendor_address, class_name: "Address", foreign_key: "address_id", optional: true
  has_many :manufacturers
  has_many :orders
  has_many :other_part_numbers, as: :company

  accepts_nested_attributes_for :vendor_address, reject_if: :all_blank

  validates :name, presence: true
  validates_uniqueness_to_tenant :name
  validates :website,
    format: {
      with: /\A#{URI.regexp(['http', 'https'])}\z/,
      message: "is invalid. Valid format: http(s)://(www.)example(.com|.net|etc)(/path/to/resource)"
    }, allow_blank: true

  def self.csv_export(vendors)
    CSV.generate do |csv|
      csv << ["Name", "Address 1", "Address 2", "City", "State", "Zip Code", "Phone Number", "Representative"]
      vendors.each do |vendor|
        csv << [vendor.name, vendor.vendor_address&.address_1, vendor.vendor_address&.address_2, vendor.vendor_address&.city, vendor.vendor_address&.state,
          vendor.vendor_address&.zip_code, vendor.phone_number, vendor.representative]
      end
    end
  end

  def self.csv_import(file, team)
    vendors_read = 0
    vendors_modified = 0
    vendors_added = 0

    map = {
      "Name" => :name,
      "Address 1" => :address_1,
      "Address 2" => :address_2,
      "City" => :city,
      "State" => :state,
      "Zip Code" => :zip_code,
      "Phone Number" => :phone_number,
      "Representative" => :representative
    }

    CSV.foreach(file, headers: true) do |row|
      vendors_read += 1
      data = { vendor_address_attributes: {} }
      row.to_hash.each do |k, v|
        key = map[k]
        if ["Name", "Phone Number", "Representative"].include? k
          data[key] = v
        else
          data[:vendor_address_attributes][key] = v
        end
      end

      data[:team_id] = team.id
      data[:organization_id] = team.organization_id

      if vendor = Vendor.find_by(name: data[:name])
        vendor.update(data)
        vendors_modified += 1 if vendor.previous_changes.length > 0
      else
        Vendor.create!(data)
        vendors_added += 1
      end
    end

    stats = ["Vendors Read: #{vendors_read}"]
    stats << "Vendors Modified: #{vendors_modified}" if vendors_modified > 0
    stats << "Vendors Added: #{vendors_added}" if vendors_added > 0
    stats.join(" | ")
  end
end
