# frozen_string_literal: true

json.extract! manufacturer, :id, :created_at, :updated_at
json.url manufacturer_url(manufacturer, format: :json)
