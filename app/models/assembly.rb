# frozen_string_literal: true

class Assembly < ApplicationRecord
  require "csv"
  require "fuzzystringmatch"
  include TeamSharing

  acts_as_tenant :organization

  belongs_to :team
  belongs_to :customer, optional: true
  has_many :subassemblies, class_name: "Subassembly", foreign_key: "parent_assembly_id"
  has_many :components
  has_many :units
  has_many :parts_received
  has_and_belongs_to_many :jobs, join_table: "units"
  has_and_belongs_to_many :parts, join_table: "components"

  validates :name, presence: true
  validates_uniqueness_to_tenant :name

  def add_part(part, quantity, org)
    current_component = components.find_by(part_id: part.id)
    if current_component
      current_component.quantity += quantity
    else
      current_component = Component.new(assembly_id: id, part_id: part.id, quantity:, organization_id: org.id)
    end
    save!
    current_component
  end

  def add_subassembly(assembly, quantity, org)
    current_subassembly = subassemblies.find_by(child_assembly_id: assembly.id)
    if current_subassembly
      current_subassembly.quantity += quantity
    else
      current_subassembly = Subassembly.new(parent_assembly_id: id, child_assembly_id: assembly.id, quantity:, organization_id: org.id, team_id:)
    end
    save!
    current_subassembly
  end

  def parts_by_assembly(vendor = nil, sequence = [])
    if vendor && !vendor.universal
      assembly_parts = parts.joins(:manufacturer).where("manufacturers.vendor_id = ?", vendor.id).map { |part| { "#{part.label}": { id: part.id, assembly_id: id, id_sequence: sequence } } }
      assembly_parts.concat parts.joins(other_part_numbers: :vendor).where("vendors.id = ?", vendor.id).map { |part| { "#{part.label}": { id: part.id, assembly_id: id, id_sequence: sequence } } }
    else
      assembly_parts = parts.map { |part| { "#{part.label}": { id: part.id, assembly_id: id, id_sequence: sequence } } }
    end
    subassemblies.each do |sa|
      assembly_parts.concat(sa.child_assembly.parts_by_assembly(vendor, sequence.dup.push(id)))
    end
    assembly_parts.uniq
  end

  def subassembly_components_count
    subassemblies.sum { |sa| sa.child_assembly.calc_total_components * sa.quantity }
  end

  def subassemblies_list(sequence, part = nil, quantity = 1)
    sequence.push(id)
    sequence_label = ""

    sequence.each do |id|
      sequence_label += Assembly.find(id).name + " > "
    end
    if part
      sub_list = subassemblies.joins(child_assembly: { components: :part }).where("parts.id": part.id)
    else
      sub_list = subassemblies
    end
    list = sub_list.map { |sa| { "#{sequence_label + sa.child_assembly.name}": { id: sa.child_assembly_id, quantity: sa.quantity * quantity, sequence: } } }.reduce(:merge) || {}

    subassemblies.each do |sa|
      list.merge!(sa.child_assembly.subassemblies_list(sequence.dup, part, sa.quantity))
    end
    list
  end

  def calc_total_components
    components.count + subassembly_components_count
  end

  def calc_total_quantity
    components_quantity = components.sum { |component| component.quantity }
    subassemblies_components_quantity = subassemblies.sum { |sa| sa.child_assembly.calc_total_quantity * sa.quantity }
    components_quantity + subassemblies_components_quantity
  end

  def calc_total_cost
    components_cost = components.sum { |component| component.part.cost_per_unit * component.quantity }
    subassemblies_cost = subassemblies.sum { |subassembly| subassembly.child_assembly.calc_total_cost * subassembly.quantity }
    components_cost + subassemblies_cost
  end

  def update_totals
    self.total_components = calc_total_components
    self.total_quantity = calc_total_quantity
    self.total_cost = calc_total_cost
    save!
  end

  def csv_import(file, format, org, team)
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
    similarity_threshold = 0.92

    case format
    when "AUTOCAD"
      map = {
        "MFG" => :manufacturer,
        "CATALOG" => :mfg_part_number,
        "QTY" => :quantity,
        "DESCRIPTION" => :description
      }
      skip = /.*,,,,,|,,,,,/
      CSV.foreach(file, headers: true, skip_blanks: true, skip_lines: skip) do |row|
        data = {}
        row.to_hash.each do |k, v|
          key = map[k]
          data[key] = v
        end
        manufacturer_name = data[:manufacturer].squish!
        Manufacturer.all.each do |m|
          if jarow.getDistance(m.name.upcase, manufacturer_name.upcase) > similarity_threshold
            data[:manufacturer] = m.id
            break
          end
        end

        if manufacturer_name == data[:manufacturer] && data[:manufacturer].present?
          manufacturer = Manufacturer.create!(name: data[:manufacturer], vendor: nil, organization_id: self.organization_id, team_id: self.team_id)
          manufacturer.save!
          data[:manufacturer] = manufacturer.id
        end

        part = Part.where(manufacturer: data[:manufacturer]).find_or_create_by(mfg_part_number: data[:mfg_part_number]) do |part|
          part.manufacturer_id = data[:manufacturer]
          part.description = data[:description]
          part.cost_per_unit = 0
        end
        part.org_part_number = Part.next_org_part_number
        part.organization = self.organization
        part.team = self.team
        part.skip_mfg_validations = true
        part.save!

        component = add_part(part, data[:quantity].to_i, org)
        component.save!
      end
    when "MECO"
      meco = Customer.create_with(team_id: team.id).find_or_create_by(name: "MECO")
      map = {
        "Part Number" => :meco_part_number,
        "Notes Text" => :description,
        "Unit Qty" => :quantity
      }
      skip = /MECHANICAL EQUIP CO., INC|MECO - Indented Bill of Material|Effective Items Only As of:|Assy#|Purch Assy Flag:|,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,/
      CSV.foreach(file, headers: true, skip_blanks: true, skip_lines: skip) do |row|
        data = {}
        row.to_hash.each do |k, v|
          key = map[k]
          data[key] = v
        end
        data[:meco_part_number].tr!("_", "")

        part = nil

        other_part_number = OtherPartNumber.find_by(company_type: "Customer", company_id: meco.id, company_name: meco.name, part_number: data[:meco_part_number])
        if other_part_number
          part = other_part_number.part
        else
          Part.all.each do |pt|
            next unless pt.manufacturer && pt.mfg_part_number && data[:description].upcase.include?(pt.manufacturer.name.upcase) &&
                        data[:description].upcase.include?(pt.mfg_part_number.upcase) && pt.other_part_numbers.where(company_id: meco.id).count == 0
            part = pt
            OtherPartNumber.find_or_create_by(part_id: pt.id, company_type: "Customer", company_id: meco.id, company_name: meco.name, part_number: data[:meco_part_number])
            break
          end
        end

        unless part
          Manufacturer.all.each do |m|
            name_length = m.name.split(" ").length
            data[:description].each_line do |line|
              line.split(" ").each_with_index do |_word, i|
                next unless jarow.getDistance(m.name.upcase,
                                              line.split(" ")[i..i + name_length - 1].join(" ").upcase) > similarity_threshold

                data[:manufacturer] = m
                part_num = line.split("#")[1]
                part_num = part_num.split(" ")[0] unless part_num.nil?
                part_num = part_num.split(",")[0] unless part_num.nil?
                data[:mfg_part_number] = part_num
                break
              end
            end
          end

          part = Part.new(data.except(nil, :quantity, :meco_part_number))

          if data[:manufacturer] && data[:mfg_part_number] && Part.exists?(manufacturer_id: data[:manufacturer], mfg_part_number: data[:mfg_part_number])
            i = 1
            while Part.exists?(manufacturer_id: data[:manufacturer], mfg_part_number: data[:mfg_part_number] + " (#{i})")
              i += 1
            end
            part.mfg_part_number = data[:mfg_part_number] + " (#{i})"
          end

          part.cost_per_unit = 0
          part.org_part_number = Part.next_org_part_number
          part.organization = self.organization
          part.team = self.team
          part.skip_mfg_validations = true
          part.save!
          OtherPartNumber.create!(part_id: part.id, company_type: "Customer", company_id: meco.id, company_name: meco.name, part_number: data[:meco_part_number])
        end

        component = add_part(part, data[:quantity].to_i, org)
        component.save!
      end
    end
  end

  def csv(**options)
    CSV.generate do |csv|
      csv_assembly_tables(csv, options)
      csv_subassembly_tables(csv, options)
    end
  end

  def csv_assembly_tables(csv, options)
    if options[:include_cost]
      csv << ["Name", "Total Components", "Total Quantity", "Total Cost"]
      csv << [name, components.count, components.sum(&:quantity), total_cost]
    else
      csv << ["Name", "Total Components", "Total Quantity"]
      csv << [name, components.count, components.sum(&:quantity)]
    end

    csv << [""]
    if options[:include_cost]
      csv << ["Part", "Cost per Unit", "Quantity", "Total Cost"]
      components.each do |c|
        csv << [c.part.label, c.part.cost_per_unit, c.quantity, c.part.cost_per_unit * c.quantity]
      end
    else
      csv << ["Part", "Quantity"]
      components.each do |c|
        csv << [c.part.label, c.quantity]
      end
    end
  end

  def csv_subassembly_tables(csv, options)
    if subassemblies.any?
      csv << [""]
      csv << ["#{name} subassemblies"]
    end
    subassemblies.each do |sa|
      csv << [""]
      sa.child_assembly.csv_assembly_tables(csv, options)
    end
    subassemblies.each do |sa|
      sa.child_assembly.csv_subassembly_tables(csv, options)
    end
  end

  def filename
    "#{name}_#{Date.today}"
  end

  def pdf(**options)
    html = AssembliesController.new.render_to_string({
      template: "assemblies/pdf",
      layout: "pdf",
      locals: { assembly: self, job: nil, customer:, include_cost: options[:include_cost] }
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
    name
  end
end
