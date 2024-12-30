# frozen_string_literal: true

task create_primary_part_numbers: [:environment] do
  Part.all.each do |part|
    next unless part.primary_part_number == nil
    part.create_primary_part_number
  end
end
