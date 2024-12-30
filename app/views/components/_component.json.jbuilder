# frozen_string_literal: true

json.extract! component, :id, :part_id, :assembly_id, :quantity, :created_at, :updated_at
json.url component_url(component, format: :json)
