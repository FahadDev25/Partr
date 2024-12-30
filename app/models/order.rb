# frozen_string_literal: true

class Order < ApplicationRecord
  require "csv"
  include TeamSharing

  acts_as_tenant :organization

  belongs_to :team
  belongs_to :vendor, optional: true
  belongs_to :job, optional: true
  belongs_to :user
  belongs_to :ship_to, class_name: "Address", foreign_key: "address_id", optional: true
  belongs_to :billing_address, class_name: "Address", foreign_key: "billing_address_id", optional: true

  has_many :line_items
  has_many :shipments
  has_many :comments, as: :commentable
  has_many :attachments, as: :attachable

  has_and_belongs_to_many :parts, join_table: "line_items"

  accepts_nested_attributes_for :ship_to, :billing_address, reject_if: :all_blank

  validates_uniqueness_to_tenant :po_number, message: "must be unique."
  validates :vendor, presence: true, if: :job_id?

  after_update :mark_all_line_items_received, if: :mark_line_items_received && :mark_line_items_received_previously_changed?

  def all_received
    return false if quantity_received.blank? || quantity_received < total_quantity
    fully_received = true
    line_items.each do |line_item|
      fully_received = line_item.quantity_received >= line_item.quantity
      break unless fully_received
    end
    fully_received
  end

  def attach_attachments=(to_attach)
    to_attach.each_with_index do |attachment, i|
      next unless attachment.present? && (["image/png", "image/jpg", "image/jpeg"].include? slip.content_type)
      path = attachment.tempfile.path
      image = ImageProcessing::Vips.source(path)
      result = image.resize_to_limit!(1000, 1000)
      to_attach[i].tempfile = result
    end
    attachments.attach(attachments)
  end

  def filename
    [po_number, vendor&.name&.gsub(/[^0-9a-z\\s]/i, "")].compact.join("_")
  end

  def name
    [po_number, job&.name, vendor&.name, order_date].compact.join(" | ")
  end

  def add_part(part, assembly, id_sequence, quantity, discount, org)
    current_line_item = line_items.find_by(part_id: part.id, assembly_id: assembly&.id, id_sequence:)
    if current_line_item
      current_line_item.quantity += quantity
    else
      current_line_item = LineItem.new(order_id: id, part_id: part.id, cost_per_unit: part.cost_per_unit, assembly_id: assembly&.id, id_sequence:, quantity:, discount:, organization_id: org.id)
    end
    current_line_item
  end

  def job_name_number
    "#{include_job_name ? job.name : "" }#{include_job_name && include_job_number ? ", " : "" }#{include_job_number ? job.job_number : "" }"
  end

  def line_items_condensed
    list = {}
    line_items.order(:created_at).each do |line_item|
      if line_item.manual
        list.merge! ({
          line_item.description =>
          {
            sku: line_item.sku,
            quantity: line_item.quantity,
            cost_per_unit: line_item.cost_per_unit,
            discount: line_item.discount
          }
        }) { |key, old, new| {
          sku: line_item.sku,
          quantity: old[:quantity] + new[:quantity],
          cost_per_unit: new[:cost_per_unit],
          discount: new[:discount]
          }
        }
      else
        list.merge! ({
          line_item.part.label(vendor) =>
          {
            part: line_item.part,
            quantity: line_item.quantity,
            cost_per_unit: line_item.cost_per_unit,
            discount: line_item.discount
          }
        }) { |key, old, new| {
          part: new[:part],
          quantity: old[:quantity] + new[:quantity],
          cost_per_unit: new[:cost_per_unit],
          discount: new[:discount]
          }
        }
      end
    end
    list
  end

  def line_item_select_list
    list = { "none" => nil }
    list.merge! line_items.order(:sku).map { |line_item| { (line_item.part ? line_item.part_and_assembly : "#{line_item.sku} #{line_item.description}") => line_item.id } }.reduce(:merge)
  end

  def parts_list
    parts.map { |part| { "#{part.label}": part.id } }.uniq
  end

  def parts_not_received
    not_received = {}
    line_items.where.not(part_id: nil).each do |line_item|
      next unless line_item.quantity_received < line_item.quantity
      not_received.merge!({ line_item.part.label => { received: line_item.quantity_received, needed: line_item.quantity } })  {
        |key, old, new| { received: old[:received] + new[:received], needed: old[:needed] + new[:needed] }
      }
    end
    not_received.transform_values { |quantity| "#{quantity[:received]}/#{quantity[:needed]}" }
  end

  def parts_received
    ids = PartReceived.joins(:shipment).where("shipments.order_id = ?", id).pluck(:id)
    ids.append PartReceived.joins(:line_item).where("line_items.order_id = ?", id).pluck(:id)
    PartReceived.where(id: ids)
  end

  def parts_received_ordered
    "#{quantity_received.to_s.sub(/\.0+$/, '')}/#{total_quantity.to_s.sub(/\.0+$/, '')}"
  end

  def remove_part(part, quantity)
    self.update_cost
  end

  def update_cost
    self.parts_cost = line_items.sum { |line_item| line_item.cost_per_unit * line_item.quantity * (1.0 - line_item.discount.to_f) }
    self.tax_total = (parts_cost || 0) * (tax_rate || 0)
    self.total_cost = (parts_cost || 0) + (tax_total || 0) + (freight_cost || 0)
    save!
  end

  def update_total_cost
    self.total_cost = (parts_cost || 0) + (tax_total || 0) + (freight_cost || 0)
    save!
  end

  def add_all_parts_from_vendor
    job.units.each do |u|
      u.assembly.components.joins(part: :manufacturer).where("manufacturers.vendor_id = ?", vendor_id).each do |c|
        line_item = add_part(c.part, c.assembly, nil, u.quantity * c.quantity, 0.0, job.organization)
        line_item.save!
      end
      u.assembly.subassemblies.each do |subassembly|
        self.add_subassembly_parts_from_vendor(subassembly, u.quantity, vendor)
      end
    end
    job.additional_parts.each do |ap|
      if ap.part&.manufacturer&.vendor == vendor
        line_item = add_part(ap.part, nil, nil, ap.quantity, 0.0, job.organization)
        line_item.save!
      end
    end
  end

  def add_subassembly_parts_from_vendor(subassembly, quantity, vendor, id_sequence = [])
    id_sequence << subassembly.parent_assembly_id
    subassembly.child_assembly.components.joins(part: :manufacturer).where("manufacturers.vendor_id = ?", vendor_id).each do |c|
      line_item = add_part(c.part, c.assembly, id_sequence, subassembly.quantity * c.quantity * quantity, 0.0, organization)
      line_item.save!
    end
    subassembly.child_assembly.subassemblies.each { self.add_subassembly_parts_from_vendor(subassembly, quantity * subassembly.quantity, vendor, id_sequence.dup) }
  end

  def csv_format_options
    options = ["Partr"]
    options.append "AutomationDirect" if line_items.joins(part: [other_part_numbers: :vendor]).where("other_part_numbers.company_name ILIKE 'AutomationDirect' OR other_part_numbers.company_name ILIKE 'Automation Direct'").any?
    options
  end

  def csv(**options)
    case options[:export_format]
    when "Partr"
      CSV.generate do |csv|
        csv << ["Mechanical Systems Inc", "", "", "", "Date", Date.today.strftime("%B %e, %Y")]
        csv << ["", "", "", "", "PO #", po_number]
        csv << ["", "", "", "", "Job #", job&.name || "-"]
        csv << [""]
        csv << ["Purchase From", "", "", "", "", "Bill to"]
        csv << [vendor&.name, "", "", "", "", organization&.name]
        csv << [vendor.vendor_address&.address_1, "", "", "", "", ship_to&.address_1]
        csv << [vendor.vendor_address&.address_2, "", "", "", "", ship_to&.address_2] if vendor.vendor_address&.address_2 || ship_to&.address_2
        csv << ["#{vendor.vendor_address&.city} #{vendor.vendor_address&.state}, #{vendor.vendor_address&.zip_code}", "", "", "", "", "#{ship_to&.city} #{ship_to&.state}, #{ship_to&.zip_code}"]
        csv << [vendor&.phone_number, "", "", "", "", ""]
        csv << ["ATTN: #{vendor&.representative}", "", "", "", "", ""]
        csv << [""]
        csv << ["Qty", "Item #", "Description", "Unit Price", "Discount", "Line Total"]

        line_items_condensed.each do |label, details|
          csv << [
            details[:quantity],
            details[:part] ? label : "-",
            details[:part]&.description || label,
            details[:cost_per_unit],
            details[:discount] && details[:discount] > 0 ? details[:discount] : "",
            details[:cost_per_unit] * details[:quantity] * (1 - (details[:discount] || 0))
          ]
        end
        csv << ["", "", "", "", "Subtotal", parts_cost]
        csv << ["", "", "", "", "Freight", freight_cost]
        csv << ["", "", "", "", "Sales Tax", (tax_rate || 0) * (parts_cost || 0)]
        csv << ["", "", "", "", "Total", (parts_cost || 0) * (1 + (tax_rate || 0)) + freight_cost]
      end
    when "AutomationDirect"
      automation_direct = Vendor.find_by("LOWER(name) = 'automation direct'") || Vendor.find_by("LOWER(name) = 'automationdirect'")
      CSV.generate do |csv|
        line_items_condensed.each do |label, details|
          csv << [
            details[:part].other_part_numbers.find_by(company_type: "Vendor", company_id: automation_direct&.id)&.part_number,
            details[:quantity]
          ]
        end
      end
    end
  end

  def pdf_boolean_options
    { include_job_name: { label: "Include Job Name", default: true }, include_job_number: { label: "Include Job Number", default: true } } if job_id
  end

  def pdf_format_options
    ["PO", "RFQ"]
  end

  def pdf(**options)
    case options[:export_format]
    when "PO"
      format = {
        type: "Purchase Order",
        type_abbr: "PO",
        show_prices: true
      }
    when "RFQ"
      format = {
        type: "Request for Quote",
        type_abbr: "RFQ",
        show_prices: false
      }
    end

    options = {
      include_job_name: options[:include_job_name],
      include_job_number: options[:include_job_number]
    }

    html = OrdersController.new.render_to_string({
      template: "orders/po",
      layout: "pdf",
      locals: { order: self, format:, options: }
    })

    footer = AssembliesController.new.render_to_string({
      partial: "pages/pdf_footer",
      locals: { object: self }
    })

    browser = Ferrum::Browser.new({ browser_options: { 'no-sandbox': nil } })
    page = browser.create_page
    page.frames[0].content = html
    pdf = page.pdf(
      encoding: :binary,
      display_header_footer: true,
      header_template: "<span></span>",
      footer_template: footer,
      margin_bottom: 0.75
    )
    browser.quit
    pdf
  end

  def title
    po_number
  end

  def ordered_assemblies(part)
    line_items.where.not(assembly_id: nil).where(part_id: part.id).map { |li| { "#{li.sequence_label}": { id: li.assembly_id, sequence: li.id_sequence } } }
  end

  def ordered_parts
    line_items.where.not(part_id: nil).map { |li| { "#{li.part.label}": { id: li.part.id, assembly_id: li.assembly_id, id_sequence: li.id_sequence || [] } } }
  end

  def unordered_assemblies(part, mode = "new")
    return Assembly.joins(:parts).where("parts.id = ?", part.id).map { |assembly| { assembly.name => { id: assembly.id, sequence: [] } } } if job_id == nil
    job.assembly_list(part).to_a.map { |a| { a[0] => { id: a[1][:id], sequence: a[1][:sequence] } } } - (mode == "edit" ? [] : ordered_assemblies(part))
  end

  def unordered_parts(mode = "new")
    if job_id == nil || job.parts_list.none?
      if vendor.present?
        parts = team.parts.where(manufacturer_id: self&.vendor&.manufacturers&.pluck(:id))
      else
        parts = team.parts
      end
      parts.map { |part| { "#{part.label}": { id: part.id, assembly_id: nil, id_sequence: [] } } } - (mode == "edit" ? [] : ordered_parts)
    else
      job.parts_by_assembly(self.vendor) - (mode == "edit" ? [] : ordered_parts)
    end
  end

  # class methods
  def self.next_po_number(prefix)
    year = (Date.today.year % 100).to_s
    last_order = Order.where("po_number like ?", "#{prefix}-#{year}%").order(:po_number).last
    number = last_order ? (last_order.po_number[(prefix.length + 3)..-1].to_i + 1) : 1
    prefix + "-" + year + number.to_s.rjust(3, "0")
  end

  private
    def mark_all_line_items_received
      line_items.each do |line_item|
        quantity_needed = line_item.quantity - line_item.parts_received.sum(&:quantity)
        next unless  quantity_needed >= 0
        PartReceived.create!(
          job_id:,
          line_item_id: line_item.id,
          assembly_id: line_item.assembly_id,
          part_id: line_item.part_id,
          quantity: quantity_needed,
          shipment_id: nil,
          id_sequence: line_item.id_sequence,
          description: line_item.description
        )
      end
    end
end
