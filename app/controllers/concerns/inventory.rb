# frozen_string_literal: true

module Inventory
  # usable with unit or additional_part
  def fill_from_inventory(item, component = nil)
    amount = component ? item.quantity_needed(component) : item.quantity_needed
    assembly = component ? item&.assembly_id : nil
    part = component ? component.part : item.part
    amount = part.in_stock if part.in_stock < amount

    part_received = PartReceived.find_or_create_by({ assembly_id: assembly, part_id: part.id, job_id: item.job_id, shipment_id: nil, id_sequence: nil })
    if part_received.quantity
      part_received.quantity += amount
    else
      part_received.quantity = amount
    end
    part_received.save!

    part.remove_stock(amount)
  end

  def subassembly_fill_from_inventory(unit, unit_subassembly, component)
    amount = [unit.subassembly_quantity_needed(unit_subassembly, component), component.part.in_stock].min
    assembly_id = unit_subassembly[:id]

    part_received = PartReceived.find_or_create_by({ assembly_id:, part_id: component.part_id, job_id: unit.job_id, shipment_id: nil, id_sequence: unit_subassembly[:sequence] })
    part_received.quantity = part_received.quantity.to_i + amount
    part_received.save!

    component.part.remove_stock(amount)
  end

  def gen_qr_code(link)
    qrcode = RQRCode::QRCode.new(link)

    qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 240
    )
  end
end
