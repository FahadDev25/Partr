# frozen_string_literal: true

json.extract! unit, :id, :job_id, :assembly_id, :quantity, :created_at, :updated_at
json.url unit_url(unit, format: :json)
