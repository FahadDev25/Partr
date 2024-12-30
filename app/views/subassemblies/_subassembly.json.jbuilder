# frozen_string_literal: true

json.extract! subassembly, :id, :parent_assembly_id, :child_assembly_id, :created_at, :updated_at
json.url subassembly_url(subassembly, format: :json)
