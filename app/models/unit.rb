# frozen_string_literal: true

class Unit < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :job
  belongs_to :assembly

  validates :quantity, numericality: { greater_than_or_equal_to: 1 }

  def parts_needed_in_stock
    assembly.components.each do |c|
      next unless parts_received.where(part_id: c.part.id).sum(&:quantity) < (c.quantity * quantity)
      return true if c.part.in_stock && c.part.in_stock > 0
    end
    false
  end

  def parts_ordered
    LineItem.where(assembly_id:, id_sequence: nil).joins(:order).where("orders.order_date <= current_date AND orders.job_id = ?", job_id)
  end

  def parts_received
    PartReceived.where(assembly_id:, job_id:, id_sequence: nil)
  end

  def subassembly_parts_ordered(subassembly)
    LineItem.where(assembly_id: subassembly[:id], id_sequence: subassembly[:sequence]).joins(:order).where("orders.job_id = ?", job_id)
  end

  def subassembly_parts_received(subassembly)
    PartReceived.where(assembly_id: subassembly[:id], job_id:, id_sequence: subassembly[:sequence])
  end

  def part_ordered_required(part)
    ordered = parts_ordered.where(part_id: part.id).sum(&:quantity)
    required = assembly.components.where(part_id: part.id).sum(&:quantity) * quantity
    "#{ordered.to_s.sub(/\.0+$/, '')}/#{required.to_s.sub(/\.0+$/, '')}"
  end

  def part_received_required(part)
    received = parts_received.where(part_id: part.id).sum(&:quantity)
    required = assembly.components.where(part_id: part.id).sum(&:quantity) * quantity
    "#{received.to_s.sub(/\.0+$/, '')}/#{required.to_s.sub(/\.0+$/, '')}"
  end

  def subassembly_part_received_required(part, subassembly)
    received = subassembly_parts_received(subassembly).where(part_id: part.id).sum(&:quantity)
    required = Component.where(part_id: part.id, assembly_id: subassembly[:id]).sum(&:quantity) * subassembly[:quantity].to_i
    "#{received.to_s.sub(/\.0+$/, '')}/#{required.to_s.sub(/\.0+$/, '')}"
  end

  def parts_ordered_required
    ordered = parts_ordered.sum(&:quantity)
    subassemblies_list.each_value do |sa|
      ordered += subassembly_parts_ordered(sa).sum(&:quantity)
    end
    required = assembly.total_quantity * quantity
    all_ordered = true
    assembly.components.each do |component|
      all_ordered = false if component.quantity > parts_ordered.where(part_id: component.part_id).sum(&:quantity)
    end
    subassemblies_list.each_value do |sa|
      Assembly.find(sa[:id]).components.each do |component|
        all_ordered = false if component.quantity > subassembly_parts_ordered(sa).where(part_id: component.part_id).sum(&:quantity)
      end
    end
    "#{ordered.to_s.sub(/\.0+$/, '')}/#{required.to_s.sub(/\.0+$/, '')}" + (all_ordered ? " \u2714" : "")
  end

  def parts_received_required
    received = parts_received.sum(&:quantity)
    subassemblies_list.each_value do |sa|
      received += subassembly_parts_received(sa).sum(&:quantity)
    end
    required = assembly.total_quantity * quantity
    all_received = true
    assembly.components.each do |part|
      all_received = false if quantity_needed(part) > 0
    end
    subassemblies_list.each_value do |sa|
      Assembly.find(sa[:id]).components.each do |component|
        all_received = false if subassembly_quantity_needed(sa, component) > 0
      end
    end
    "#{received.to_s.sub(/\.0+$/, '')}/#{required.to_s.sub(/\.0+$/, '')}" + (all_received ? " \u2714" : "")
  end

  def quantity_needed(component)
    received = parts_received.where(part_id: component.part_id).sum(&:quantity)
    component.quantity * quantity - received
  end

  def subassembly_quantity_needed(unit_subassembly, component)
    received = subassembly_parts_received(unit_subassembly).where(part_id: component.part_id).sum(&:quantity)
    component.quantity * unit_subassembly[:quantity].to_i - received
  end

  def subassemblies_list(part = nil)
    assembly.subassemblies_list([], part).transform_values! { |v| { id: v[:id], quantity: v[:quantity] * quantity, sequence: v[:sequence] } }
  end

  def pdf(**options)
    html = AssembliesController.new.render_to_string({
      template: "assemblies/pdf",
      layout: "pdf",
      locals: { assembly:, job:, customer: job.customer, include_cost: options[:include_cost] }
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

  def csv(**options)
    assembly.csv(**options)
  end

  def title
    "#{job.name}: #{assembly.name}"
  end

  def filename
    "#{job.name}_#{assembly.name}"
  end
end
