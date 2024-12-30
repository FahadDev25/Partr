# frozen_string_literal: true

json.extract! additional_part, :id, :job_id, :part_id, :quantity, :created_at, :updated_at
json.url additional_part_url(additional_part, format: :json)
