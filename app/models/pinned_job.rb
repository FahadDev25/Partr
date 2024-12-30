# frozen_string_literal: true

class PinnedJob < ApplicationRecord
  acts_as_tenant :organization
  belongs_to :team
  belongs_to :user
  belongs_to :job
end
