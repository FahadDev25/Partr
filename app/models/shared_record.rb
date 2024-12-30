# frozen_string_literal: true

class SharedRecord < ApplicationRecord
  belongs_to :shareable, polymorphic: true
  belongs_to :team
  belongs_to :organization
end
