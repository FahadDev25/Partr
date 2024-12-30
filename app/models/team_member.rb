# frozen_string_literal: true

class TeamMember < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :user
  belongs_to :team
  belongs_to :organization
end
