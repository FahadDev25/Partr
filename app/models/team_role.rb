# frozen_string_literal: true

class TeamRole < ApplicationRecord
  acts_as_tenant :organization
  has_many :teams

  alias_attribute :name, :role_name
end
