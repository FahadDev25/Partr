# frozen_string_literal: true

class Part < ApplicationRecord
  require "csv"
  require "rqrcode"
  require "open-uri"
  include ActiveModel::Dirty
  include Rails.application.routes.url_helpers
  include Inventory
  include ImportExport
  include TeamSharing

  attr_accessor :skip_mfg_validations

  acts_as_tenant :organization

  belongs_to :team
  belongs_to :manufacturer, optional: true
  has_many :other_part_numbers, dependent: :destroy
  has_many :components
  has_many :line_items
  has_many :parts_received
  has_and_belongs_to_many :assemblies, join_table: "components"
  has_and_belongs_to_many :orders, join_table: "line_items"

  validates :in_stock, :cost_per_unit, numericality: { greater_than_or_equal_to: 0 }
  validates :in_stock, numericality: true
  validates_uniqueness_to_tenant :mfg_part_number, scope: :manufacturer_id, allow_blank: true, unless: Proc.new { |p| p.manufacturer_id.blank? }
  validates :org_part_number, presence: true
  validates_uniqueness_to_tenant :org_part_number
  validates :manufacturer_id, :mfg_part_number, presence: true,  unless: :skip_mfg_validations
  validates :url,
    format: {
      with: /\A#{URI.regexp(['http', 'https'])}\z/,
      message: "is invalid. Valid format: http(s)://(www.)example(.com|.net|etc)(/path/to/part)"
    }, allow_blank: true

  after_create :create_primary_part_number
  after_save :touch_components

  def add_stock(quantity)
    if self.in_stock
      self.in_stock += quantity
    else
      self.in_stock = quantity
    end
    save!
  end

  def create_primary_part_number
    OtherPartNumber.create!(
      part_id: id,
      company_type: "Manufacturer",
      company_id: manufacturer_id,
      company_name: manufacturer&.name,
      part_number: mfg_part_number,
      primary: true,
      cost_per_unit:,
      last_price_update:,
      organization_id:
    )
  end

  def label(vendor = nil)
    return "#{manufacturer.name} #{mfg_part_number}" if  manufacturer && mfg_part_number && (vendor == nil || vendor.universal || vendor == manufacturer.vendor)
    return "#{vendor_part_number(vendor).company_name} #{vendor_part_number(vendor).part_number}" if vendor && vendor_part_number(vendor)
    "#{organization.abbr_name} #{org_part_number}"
  end

  def price_changes
    other_part_numbers.where("cost_per_unit > 0").map { |opn| { name: opn.company_name, data: opn.price_changes.pluck(:date_changed, :cost_per_unit) } }
  end

  def price_changes?
    other_part_numbers.joins(:price_changes).any?
  end

  def primary_part_number
    other_part_numbers.find_by(primary: true)
  end

  def remove_stock(quantity)
    if self.in_stock && self.in_stock > quantity
      self.in_stock -= quantity
    else
      self.in_stock = 0
    end
    self.save!
  end

  def staleness
    return "fresh" unless team.stale || team.warn
    price_age = (Date.today - (last_price_update || Date.new)).to_i
    return "stale" if team.stale && (price_age > team.stale)
    return "warn" if team.warn && (price_age > team.warn)
    "fresh"
  end

  def touch_components
    components.each { |c| c.touch }
  end

  def update_primary_part_number
    part_number = primary_part_number
    if self.manufacturer_id_previously_changed?
      part_number.company_id = manufacturer_id
      part_number.company_name = manufacturer.name
      part_number.save!
    end
    if self.mfg_part_number_previously_changed?
      part_number.part_number = mfg_part_number
      part_number.save!
    end
    if self.cost_per_unit_previously_changed?
      part_number.cost_per_unit = cost_per_unit
      part_number.last_price_update = Date.today
      part_number.save!
      PriceChange.create!(
        other_part_number_id: part_number.id,
        date_changed: Date.today,
        cost_per_unit: part_number.cost_per_unit,
        organization_id:)
    end
  end

  def vendor_part_number(vendor)
    return nil if vendor == nil
    part_number = other_part_numbers.find_by(company_type: "Vendor", company_id: vendor.id)
    return part_number if part_number
    other_part_numbers.joins(:manufacturer).find_by("manufacturers.vendor_id = ?", vendor.id)
  end

  def self.human_attribute_name(*args)
    if args[0].to_s == "org_part_number"
      return "Organization part number"
    end
    super
  end

  def self.next_org_part_number
    return (Part.all.order(:org_part_number).last.org_part_number.to_i + 1).to_s if Part.any?
    "1000000001"
  end

  private
    def generate_qr_code
      host = Rails.application.routes.default_url_options[:host]
      gen_qr_code(quick_links_part_url(self, host:))
    end
end
