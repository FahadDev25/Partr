# frozen_string_literal: true

json.extract! other_part_number, :id, :opn_type, :company, :part_number, :part_id, :organization_id, :created_at, :updated_at
json.url other_part_number_url(other_part_number, format: :json)
