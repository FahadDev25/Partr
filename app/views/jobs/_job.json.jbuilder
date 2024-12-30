# frozen_string_literal: true

json.extract! job, :id, :name, :status, :start_date, :deadline, :total_cost, :customer_id, :created_at, :updated_at
json.url job_url(job, format: :json)
