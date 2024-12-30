# frozen_string_literal: true

class Component < ApplicationRecord
  acts_as_tenant :organization
  after_save :update_assembly_totals
  after_touch :update_assembly_totals
  after_destroy :update_assembly_totals

  belongs_to :part
  belongs_to :assembly

  validates :quantity, numericality: { greater_than_or_equal_to: 1 }

  def label
    "#{assembly.name} | #{part.label}"
  end

  def update_assembly_totals
    assembly.update_totals
  end
end
