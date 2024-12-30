# frozen_string_literal: true

json.extract! shipment, :id, :from, :shipping_number, :date_received, :notes, :job_id, :order_id, :created_at,
              :updated_at
json.url shipment_url(shipment, format: :json)
