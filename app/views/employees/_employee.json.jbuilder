# frozen_string_literal: true

json.extract! employee, :id, :user_id, :organization_id, :created_at, :updated_at
json.url employee_url(employee, format: :json)
