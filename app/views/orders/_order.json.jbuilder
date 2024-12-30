# frozen_string_literal: true

json.extract! order, :id, :parts_cost, :order_date, :vendor_id, :job_id, :created_at, :updated_at
json.url order_url(order, format: :json)
