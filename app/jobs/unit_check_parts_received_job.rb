# frozen_string_literal: true

class UnitCheckPartsReceivedJob < ApplicationJob
  queue_as :default

  def perform(unit, mail_to)
    all_received = true
    parts_received = unit.parts_received
    unit.assembly.components.each do |c|
      next unless parts_received.where(part_id: c.part_id).sum { |pt| pt.quantity } < c.quantity * unit.quantity
      all_received = false
      break
    end
    unit.subassemblies_list.each_value do |sa|
      subassembly_parts_received = unit.subassembly_parts_received(sa)
      Assembly.find(sa[:id]).components.each do |c|
        next unless subassembly_parts_received.where(part_id: c.part_id).sum { |pt| pt.quantity } < c.quantity * sa[:quantity]
        all_received = false
        break
      end
    end

    unit.received = all_received
    unit.save!
    if all_received
      all_match = true
      mismatched_parts = {}
      unit.assembly.components.each do |c|
        quantity_received = parts_received.where(part_id: c.part_id).sum { |pt| pt.quantity }
        next unless quantity_received > c.quantity * unit.quantity
        mismatched_parts[c.part.label] = ("#{quantity_received}/#{c.quantity * unit.quantity}")
        all_match = false
      end
      subassembly_mismatched_parts = {}
      unit.subassemblies_list.each_value do |sa|
        subassembly_parts_received = unit.subassembly_parts_received(sa)
        Assembly.find(sa[:id]).components.each do |c|
          quantity_received = subassembly_parts_received.where(part_id: c.part_id).sum { |pt| pt.quantity }
          next unless quantity_received > c.quantity * sa[:quantity]
          name = ""
          Array(sa[:id_sequence]).each do |id|
            name += "#{Assembly.find(id).name} > "
          end
          name += Assembly.find(sa[:id]).name
          subassembly_mismatched_parts[name] = [] if !subassembly_mismatched_parts.has_key? name
          subassembly_mismatched_parts[name] << [c.part.label, "#{quantity_received}/#{c.quantity * unit.quantity}"]
          all_match = false
        end
      end

      UnitMailer.part_quantity_mismatch(unit, mismatched_parts, subassembly_mismatched_parts, mail_to).deliver_later if !all_match
    end
  end
end
