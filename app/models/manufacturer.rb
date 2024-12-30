# frozen_string_literal: true

class Manufacturer < ApplicationRecord
  require "csv"
  require "fuzzystringmatch"

  acts_as_tenant :organization

  has_many :parts
  belongs_to :team
  belongs_to :vendor, optional: true
  has_many :other_part_numbers, as: :company

  validates :name, presence: true
  validates_uniqueness_to_tenant :name

  def self.csv_export(manufacturers)
    CSV.generate do |csv|
      csv << ["Name", "Vendor"]
      manufacturers.each do |m|
        csv << [m.name, m&.vendor&.name]
      end
    end
  end

  def self.csv_import(file, team)
    manufacturers_read = 0
    manufacturers_modified = 0
    manufacturers_added = 0
    vendors_added = 0

    map = {
      "Name" => :name,
      "Vendor" => :vendor_name
    }

    CSV.foreach(file, headers: true) do |row|
      manufacturers_read += 1
      data = {}
      row.to_hash.each do |k, v|
        key = map[k]
        data[key] = v
      end

      if data[:vendor_name]
        if vendor = Vendor.find_by(name: data[:vendor_name])
          vendor_id = vendor.id
        else
          vendor_id = Vendor.create!(name: data[:vendor_name], team_id: team.id, organization_id: team.organization_id).id
          vendors_added += 1
        end
      else
        vendor_id = nil
      end

      if manufacturer = Manufacturer.find_by(name: data[:name])
        manufacturers_modified += 1 if manufacturer.vendor_id != vendor_id
      else
        manufacturer = Manufacturer.create(name: data[:name], team_id: team.id, organization_id: team.organization_id)
        manufacturers_added += 1
      end
      manufacturer.vendor_id = vendor_id if manufacturer.vendor_id != vendor_id
      manufacturer.save!
    end

    stats = ["Manufacturers Read: #{manufacturers_read}"]
    stats << "Manufacturers Modified: #{manufacturers_modified}" if manufacturers_modified > 0
    stats << "Manufacturers Added: #{manufacturers_added}" if manufacturers_added > 0
    stats << "Vendors Added: #{vendors_added}" if vendors_added > 0
    stats.join(" | ")
  end
end
