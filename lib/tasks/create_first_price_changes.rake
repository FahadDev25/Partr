# frozen_string_literal: true

task create_first_price_changes: [:environment] do
  OtherPartNumber.where("cost_per_unit > 0").each do |opn|
    PriceChange.create(
      date_changed: Date.today,
      cost_per_unit: opn.cost_per_unit,
      other_part_number_id: opn.id,
      organization_id: opn.organization_id
    )
  end
end
