# frozen_string_literal: true

json.array! @parts_received, partial: "parts_received/part_received", as: :part_received
