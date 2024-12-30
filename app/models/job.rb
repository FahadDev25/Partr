# frozen_string_literal: true

class Job < ApplicationRecord
  require "csv"
  include TeamSharing

  acts_as_tenant :organization

  belongs_to :team
  belongs_to :customer
  belongs_to :project_manager, class_name: "User", optional: true
  belongs_to :jobsite, class_name: "Address", foreign_key: "address_id", optional: true

  has_many :units
  has_many :orders
  has_many :shipments
  has_many :additional_parts
  has_many :parts_received
  has_many :comments, as: :commentable
  has_many :attachments, as: :attachable
  has_many :pinned_jobs, dependent: :destroy

  has_and_belongs_to_many :assemblies, join_table: "units"

  accepts_nested_attributes_for :jobsite, reject_if: :all_blank

  validates :name, presence: true
  validates_uniqueness_to_tenant :job_number, allow_blank: true
  validates_uniqueness_to_tenant :name

  def add_assembly(assembly, quantity, org)
    current_unit = units.find_by(assembly_id: assembly.id, job_id: id)
    if current_unit
      current_unit.quantity += quantity
    else
      current_unit = Unit.create!(job_id: id, assembly_id: assembly.id, quantity:, organization_id: org.id)
    end
    self.total_cost += (assembly.total_cost * quantity)
    save!
    current_unit
  end

  def add_part(part, quantity)
    current_additional_part = AdditionalPart.find_by(part_id: part.id, job_id: id)
    if current_additional_part
      current_additional_part.quantity += quantity
    else
      current_additional_part = AdditionalPart.create!(job_id: id, part_id: part.id, quantity:)
    end
    self.total_cost += (part.cost_per_unit * quantity)
    save!
    current_additional_part
  end

  def remove_assembly(assembly, quantity)
    self.total_cost -= (assembly.total_cost * quantity)
    save!
  end

  def remove_part(part, quantity)
    self.total_cost -= (part.cost_per_unit * quantity)
    save!
  end

  def update_cost
    self.total_cost = units.sum { |u| u.assembly.total_cost * u.quantity }
    self.total_cost += additional_parts.sum { |ap| ap.part.cost_per_unit * ap.quantity }
    save!
  end

  def csv_export
    CSV.generate do |csv|
      csv << ["Name", "Customer", "", "Total Cost"]
      csv << [name, customer.name, "", total_cost]

      units.each do |u|
        csv << [""]
        csv << ["Assembly", "Cost per Unit", "Quantity", "Total Cost"]
        csv << [u.assembly.name, u.assembly.total_cost, u.quantity, u.assembly.total_cost * u.quantity]
        csv << [""]
        csv << ["Part", "Cost per Unit", "Quantity", "Total Cost"]
        u.assembly.components.each do |c|
          csv << [c.part.label, c.part.cost_per_unit, c.quantity * u.quantity,
                  c.part.cost_per_unit * c.quantity * u.quantity]
        end
      end
    end
  end

  def assembly_list(part = nil)
    if part
      units_list = units.joins(assembly: { components: :part }).where("parts.id": part.id)
    else
      units_list = units
    end

    list = units_list.map { |unit| { "#{unit.assembly.name}": { id: unit.assembly_id, quantity: unit.quantity, sequence: nil } } }.reduce(:merge) || {}

    units.each do |unit|
      list.merge!(unit.subassemblies_list(part)) { |key, old, new| { id: new[:id], quantity: new[:quantity] + old[:quantity] } }
    end
    list
  end

  def parts_by_assembly(vendor = nil)
    parts = []
    if units.any?
      units.each do |unit|
        parts.concat(unit.assembly.parts_by_assembly(vendor)).uniq!
      end
    end
    if vendor && !vendor.universal
      parts.concat(Part.where(
        id: additional_parts.joins(part: :manufacturer).where("manufacturers.vendor_id = ?", vendor.id).pluck(:part_id)
      ).map { |part| { "#{part.label}": { id: part.id, assembly_id: nil, id_sequence: [] } } })
      parts.concat(Part.where(
        id: additional_parts.joins(part: [other_part_numbers: :vendor]).where("vendors.id = ?", vendor.id).pluck(:part_id)
      ).map { |part| { "#{part.label}": { id: part.id, assembly_id: nil, id_sequence: [] } } })
    else
      parts.concat(Part.where(id: additional_parts.pluck(:part_id)).map { |part| { "#{part.label}": { id: part.id, assembly_id: nil, id_sequence: [] } } })
    end
  end

  def parts_list(vendor = nil)
    part_ids = []
    if units.any?
      assembly_ids = assembly_list.values.pluck(:id).uniq
      part_ids = Component.distinct.where(assembly_id: assembly_ids).pluck(:part_id)
    end
    part_ids.concat(additional_parts.pluck(:part_id))
    parts = Part.where(id: part_ids)
    part_ids = []
    if vendor
      if vendor.universal
        parts = Part.all
      else
        part_ids.concat(parts.joins(:manufacturer).where("manufacturers.vendor_id = ?", vendor.id).pluck(:id))
        part_ids.concat(
          parts.joins(:other_part_numbers)
          .where("other_part_numbers.company_type= ?", "Vendor")
          .where("other_part_numbers.company_id= ?", vendor.id)
          .pluck(:id)
        )
        part_ids.concat(
          parts.joins(other_part_numbers: :manufacturer)
          .where("manufacturers.vendor_id= ?", vendor.id)
          .pluck(:id)
        )
        parts = Part.where(id: part_ids)
      end
    end
    parts.map { |part| { "#{part.label}": part.id } }.uniq
  end

  def vendor_list
    if units.any?
      assembly_ids = assembly_list.values.pluck(:id).uniq
      part_ids = Component.distinct.where(assembly_id: assembly_ids).pluck(:part_id)
    else
      part_ids = []
    end
    part_ids.concat(additional_parts.pluck(:part_id))
    parts = Part.distinct.where(id: part_ids)
    vendor_ids = parts.joins(:manufacturer).pluck(:vendor_id)
    vendor_ids.concat(parts.joins(:other_part_numbers).where("other_part_numbers.company_type= ?", "Vendor").pluck(:company_id))
    vendor_ids.concat(parts.joins(other_part_numbers: :manufacturer).pluck("manufacturers.vendor_id"))
    Vendor.where(id: vendor_ids).or(Vendor.where(universal: true)).map { |vendor| { "#{vendor.name}": vendor.id } }
  end

  # Class Methods

  def self.next_job_number(prefix)
    return "" if prefix.blank?
    job_numbers = Job.where("job_number LIKE ?", prefix + "%").pluck(:job_number)
    job_numbers.map! { |num| (num.gsub(prefix, "").scan(/^\d*[a-zA-Z\W]+/).count > 0 ? 0 : num.gsub(prefix, "").scan(/\d+/).last.to_i) }
    job_number = job_numbers.max.to_i + 1
    prefix + job_number.to_s.rjust(3, "0")
  end
end
