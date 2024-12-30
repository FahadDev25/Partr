# frozen_string_literal: true

class Address < ApplicationRecord
  acts_as_tenant :organization
end
