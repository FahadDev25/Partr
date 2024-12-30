# frozen_string_literal: true

class Employee < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :user
  belongs_to :organization

  def set_admin(bool)
    self.is_admin = bool
    save!
  end
end
