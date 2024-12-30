# frozen_string_literal: true

json.extract! assembly, :id, :name, :total_cost, :created_at, :updated_at
json.url assembly_url(assembly, format: :json)
