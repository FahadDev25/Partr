# frozen_string_literal: true

json.array! @shipments, partial: "shipments/shipment", as: :shipment
