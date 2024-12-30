# frozen_string_literal: true

class OtherPartNumber < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :part
  belongs_to :company, polymorphic: true, optional: true
  belongs_to :manufacturer, -> { where(other_part_numbers: { company_type: "Manufacturer" }) }, foreign_key: :company_id, optional: true
  belongs_to :vendor, -> { where(other_part_numbers: { company_type: "Vendor" }) }, foreign_key: :company_id, optional: true
  belongs_to :customer, -> { where(other_part_numbers: { company_type: "Customer" }) }, foreign_key: :company_id, optional: true
  has_many :price_changes, dependent: :delete_all

  validates :url,
    format: {
      with: /\A#{URI.regexp(['http', 'https'])}\z/,
      message: "is invalid. Valid format: http(s)://(www.)example(.com|.net|etc)(/path/to/part)"
    }, allow_blank: true

  def remove_other_primaries
    OtherPartNumber.where(part_id:, primary: true).where.not(id:).each do |opn|
      opn.primary = false
      opn.save!
    end
  end

  def staleness
    return "fresh" unless part.team.stale || part.team.warn
    price_age = (Date.today - (last_price_update || Date.new)).to_i
    return "stale" if part.team.stale && (price_age > part.team.stale)
    return "warn" if part.team.warn && (price_age > part.team.warn)
    "fresh"
  end

  def update_company_name
    self.company_name = company.name
    self.save!
  end

  def update_part
    part.manufacturer_id = company_id
    part.mfg_part_number = part_number
    part.cost_per_unit = cost_per_unit
    part.save!
  end
end
