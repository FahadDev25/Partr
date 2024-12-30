# frozen_string_literal: true

json.extract! part_received, :id, :shipment_id, :component_id, :quantity, :created_at, :updated_at
json.url part_received_url(part_received, format: :json)
