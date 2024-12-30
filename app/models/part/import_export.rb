# frozen_string_literal: true

module Part::ImportExport
  extend ActiveSupport::Concern
  require "fuzzystringmatch"

  def qr_code_base64
    Base64.encode64(generate_qr_code.to_s)
  end

  class_methods do
    def csv_export(parts)
      CSV.generate do |csv|
        last_part = nil
        csv << ["Org Part Number", "Manufacturer", "Mfg Part Number", "Description", "Cost per Unit", "In Stock", "Notes", "UL File Number", "UL CCN"]
        parts.each do |p|
          if last_part && last_part.other_part_numbers.any?
            csv << [""]
            csv << ["Org Part Number", "Manufacturer", "Mfg Part Number", "Description", "Cost per Unit",
                    "In Stock", "Notes", "UL File Number", "UL CCN"]
          end
          csv << [p.org_part_number, p.manufacturer&.name, p.mfg_part_number, p.description, p.cost_per_unit, p.in_stock, p.notes, p.optional_field_1, p.optional_field_2]
          if p.other_part_numbers.any?
            csv << [""]
            csv << ["Type", "Company", "Part Number"]
          end
          p.other_part_numbers.each do |opn|
            csv << [opn.company_type, opn.company_name, opn.part_number]
          end
          last_part = p
        end
      end
    end

    def csv_import(file, format, team)
      jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
      similarity_threshold = 0.92
      parts_read = 0
      parts_modified = 0
      parts_added = 0
      manufacturers_added = 0
      vendors_added = 0
      customers_added = 0
      part_man = nil

      case format
      when "Partr"
        map1 = {
          "Org Part Number" => :org_part_number,
          "Manufacturer" => :manufacturer_name,
          "Mfg Part Number" => :mfg_part_number,
          "Description" => :description,
          "Cost per Unit" => :cost_per_unit,
          "In Stock" => :in_stock,
          "Notes" => :notes,
          "UL File Number" => :optional_field_1,
          "UL CCN" => :optional_field_2
        }
        map2 = {
          "Org Part Number" => :company_type,
          "Manufacturer" => :company_name,
          "Mfg Part Number" => :part_number
        }
        map = map1
        last_part = nil
        CSV.foreach(file, headers: true) do |row|
          if row["Org Part Number"] == "Org Part Number"
            map = map1
            next
          elsif row["Org Part Number"] == "Type"
            map = map2
            next
          elsif row["Org Part Number"] == ""
            next
          end
          data = {}
          row.to_hash.each do |k, v|
            key = map[k]
            data[key] = v
          end

          data[:organization_id] = team.organization_id

          if map == map1
            data[:team_id] = team.id
            parts_read += 1
            if manufacturer = Manufacturer.find_by(name: data[:manufacturer_name])
              data[:manufacturer_id] = manufacturer.id
            elsif data[:manufacturer_name].present?
              data[:manufacturer_id] = Manufacturer.create!(name: data[:manufacturer_name], team_id: team.id, organization_id: team.organization_id).id
              manufacturers_added += 1
            end

            data[:skip_mfg_validations] = true

            if part = Part.find_by(org_part_number: data[:org_part_number])
              part.update(data.except(:manufacturer_name))
              parts_modified += 1 if part.previous_changes.length > 0
            else
              part = Part.create!(data.except(:manufacturer_name))
              parts_added += 1
            end
            last_part = part
          else
            data.delete_if { |k, v| v == nil }
            data[:part_id] = last_part.id
            case data[:company_type]
            when "Customer"
              klass = Customer
            when "Vendor"
              klass = Vendor
            when "Manufacturer"
              klass = Manufacturer
            end
            if company = klass.find_by(name: data[:company_name])
              data[:company_id] = company.id
            else
              data[:company_id] = klass.create!(name: data[:company_name], team_id: team.id, organization_id: team.organization_id).id
              case data[:company_type]
              when "Customer"
                customers_added += 1
              when "Vendor"
                vendors_added += 1
              when "Manufacturer"
                manufacturers_added += 1
              end
            end
            if other_part_number = OtherPartNumber.find_by(part_id: last_part.id, company_name: data[:company_name])
              other_part_number.update(data)
            else
              OtherPartNumber.create!(data)
            end
          end
        end
      when "Appsheet"
        meco = Customer.create_with(team_id: team.id).find_or_create_by(name: "MECO")
        map = {
          "Part Number" => :mfg_part_number,
          "MECO Part Number" => :meco_part_number,
          "Manufacturer" => :manufacturer,
          "Vendor" => :vendor,
          "Cost per Unit" => :cost_per_unit,
          "Description" => :description,
          "Notes" => :notes,
          "In Stock" => :in_stock,
          "UL File Number" => :optional_field_1,
          "UL CCN" => :optional_field_2
        }
        CSV.foreach(file, headers: true, encoding: "bom|utf-8") do |row|
          parts_read += 1
          data = {}
          row.to_hash.each do |k, v|
            key = map[k]
            data[key] = v
          end

          # find by meco part number
          if data[:meco_part_number]
            other_part_number = OtherPartNumber.find_by(company_type: "Customer", company_id: meco.id, company_name: meco.name, part_number: data[:meco_part_number])
            part = other_part_number.part if other_part_number
            if part
              # fill in part details
              # try to find manufacturer/part number in description
              if !(part.mfg_part_number && part.manufacturer)
                Manufacturer.all.each do |m|
                  name_length = m.name.split(" ").length
                  ((data[:description] || "") + (data[:notes] || "")).each_line do |line|
                    line.split(" ").each_with_index do |_word, i|
                      next unless jarow.getDistance(m.name.upcase, line.split(" ")[i..i + name_length - 1].join(" ").upcase) > similarity_threshold
                      data[:manufacturer] = m.id
                      part.manufacturer_id = data[:manufacturer]
                      part_man = Manufacturer.find(m.id)
                      part_num = line.split("#")[1]
                      part_num = part_num.split(" ")[0] unless part_num.nil?
                      part_num = part_num.split(",")[0] unless part_num.nil?
                      data[:mfg_part_number] = part_num
                      part.mfg_part_number = data[:mfg_part_number]
                      break
                    end
                  end
                end
              end
              part.cost_per_unit = data[:cost_per_unit].tr("$", "").tr(",", "") if data[:cost_per_unit] && data[:cost_per_unit].tr("$", "").tr(",", "").to_f > 0
              part.description = data[:description]
              part.notes = data [:notes]
              part.optional_field_1 = data[:optional_field_1]
              part.optional_field_2 = data [:optional_field_2]

              if part.changed?
                part.skip_mfg_validations = true
                part.save!
                parts_modified += 1
              end
            end
          end

          # find by part number & manufacturer
          if !part && data[:mfg_part_number] && data[:manufacturer]
            manufacturer_name = data[:manufacturer].squish!
            man_id = -1
            Manufacturer.all.each do |m|
              if jarow.getDistance(m.name.upcase, manufacturer_name.upcase) > similarity_threshold
                man_id = m.id
                part_man = Manufacturer.find(m.id)
                break
              end
            end
            part = Part.find_by(mfg_part_number: data[:mfg_part_number], manufacturer_id: man_id)
            if part
              # fill in part
              opn_created = false
              OtherPartNumber.find_or_create_by(part_id: part.id, company_type: "Customer", company_id: meco.id, company_name: meco.name, part_number: data[:meco_part_number]) do
                opn_created = true
              end if data[:meco_part_number]
              part.cost_per_unit = data[:cost_per_unit].tr("$", "").tr(",", "") if data[:cost_per_unit] && data[:cost_per_unit].tr("$", "").tr(",", "").to_f > 0
              part.description = data[:description]
              part.notes = data [:notes]
              part.optional_field_1 = data[:optional_field_1]
              part.optional_field_2 = data [:optional_field_2]

              if part.changed? || opn_created
                part.skip_mfg_validations = true
                part.save!
                parts_modified += 1
              end
            end
          end

          # make a new part
          if !part
            part = Part.new()
            if data[:cost_per_unit]
              part.cost_per_unit = data[:cost_per_unit].tr("$", "").tr(",", "")
            else
              part.cost_per_unit = 0
            end
            part.description = data[:description] || ""
            part.notes = data[:notes] || ""
            part.in_stock = data[:in_stock] || 0
            part.optional_field_1 = data[:optional_field_1] || ""
            part.optional_field_2 = data[:optional_field_2] || ""
            if data[:manufacturer]
              # try to match manufacturer
              manufacturer_name = data[:manufacturer].squish!
              Manufacturer.all.each do |m|
                if jarow.getDistance(m.name.upcase, manufacturer_name.upcase) > similarity_threshold
                  data[:manufacturer] = m.id
                  part_man = Manufacturer.find(m.id)
                  break
                end
              end
              # make new manufacturer
              if data[:manufacturer] == manufacturer_name && manufacturer_name.present?
                manufacturer = Manufacturer.new(name: data[:manufacturer], vendor: nil, team_id: team.id)
                manufacturer.save!
                data[:manufacturer] = manufacturer.id
                part_man = manufacturer
                manufacturers_added += 1
              end
              # try to find part number in description
              name_length = manufacturer_name.split(" ").length
              ((data[:description] || "") + (data[:notes] || "")).each_line do |line|
                line.split(" ").each_with_index do |_word, i|
                  next unless jarow.getDistance(manufacturer_name.upcase, line.split(" ")[i..i + name_length - 1].join(" ").upcase) > similarity_threshold
                  part_num = line.split("#")[1]
                  part_num = part_num.split(" ")[0] unless part_num.nil?
                  part_num = part_num.split(",")[0] unless part_num.nil?
                  data[:mfg_part_number] = part_num
                  break
                end
              end
            else
              # try to find manufacturer/part number in description
              Manufacturer.all.each do |m|
                name_length = m.name.split(" ").length
                (data[:description] + data[:notes].to_s).each_line do |line|
                  line.split(" ").each_with_index do |_word, i|
                    next unless jarow.getDistance(m.name.upcase, line.split(" ")[i..i + name_length - 1].join(" ").upcase) > similarity_threshold
                    data[:manufacturer] = m.id
                    part_man = Manufacturer.find(m.id)
                    part_num = line.split("#")[1]
                    part_num = part_num.split(" ")[0] unless part_num.nil?
                    part_num = part_num.split(",")[0] unless part_num.nil?
                    data[:mfg_part_number] = part_num
                    break
                  end
                end
              end
            end
            part.manufacturer_id = data[:manufacturer]
            part.mfg_part_number = data[:mfg_part_number] if part.manufacturer_id

            if data[:manufacturer] && data[:mfg_part_number] && Part.exists?(manufacturer_id: data[:manufacturer], mfg_part_number: data[:mfg_part_number])
              i = 1
              while Part.exists?(manufacturer_id: data[:manufacturer], mfg_part_number: data[:mfg_part_number] + " (#{i})")
                i += 1
              end
              part.mfg_part_number = data[:mfg_part_number] + " (#{i})"
            end

            part.org_part_number = Part.next_org_part_number
            part.team_id = team.id
            part.skip_mfg_validations = true
            part.save!
            OtherPartNumber.create(part_id: part.id, company_type: "Customer", company_id: meco.id, company_name: meco.name, part_number: data[:meco_part_number]) if data[:meco_part_number]

            parts_added += 1
          end

          # try to find vendor
          if data[:vendor] && !part&.manufacturer&.vendor
            vendor = nil
            vendor_name = data[:vendor].squish!
            Vendor.all.each do |v|
              next unless jarow.getDistance(v.name.upcase, vendor_name.upcase) > similarity_threshold
              vendor = v
              break
            end
            if !vendor && data[:vendor].present?
              vendor = Vendor.create!(name: data[:vendor], team_id: team.id)
              vendors_added += 1
            end

            if part_man.present?
              part_man.vendor_id = vendor&.id
              part_man.save!
            end
          end
        end
      end

      stats = ["Parts Read: #{parts_read}"]
      stats << "Parts Modified: #{parts_modified}" if parts_modified > 0
      stats << "Parts Added: #{parts_added}" if parts_added > 0
      stats << "Manufacturers Added: #{manufacturers_added}" if manufacturers_added > 0
      stats << "Vendors Added: #{vendors_added}" if vendors_added > 0
      stats << "Customers Added: #{customers_added}" if customers_added > 0
      stats.join(" | ")
    end

    def qr_codes_pdf(parts)
      html = PartsController.new.render_to_string({
        template: "parts/qr_codes",
        layout: "pdf",
        locals: { parts: }
      })

      browser = Ferrum::Browser.new({ browser_options: { 'no-sandbox': nil } })
      page = browser.create_page
      page.frames[0].content = html
      pdf = page.pdf(encoding: :binary, margin_bottom: 0, margin_left: 0, margin_right: 0)
      browser.quit
      pdf
    end
  end
end
