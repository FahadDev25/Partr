# frozen_string_literal: true

class PriceChange < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :other_part_number
end
