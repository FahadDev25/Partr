# frozen_string_literal: true

json.extract! team_role, :id, :organization_id, :create_destroy_job, :all_job, :all_order, :all_shipment, :created_at, :updated_at
json.url team_role_url(team_role, format: :json)
