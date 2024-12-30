# frozen_string_literal: true

json.extract! part, :id, :mfg_part_number, :description, :cost_per_unit, :in_stock, :notes, :created_at, :updated_at
json.url part_url(part, format: :json)
