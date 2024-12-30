# frozen_string_literal: true

class Subassembly < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :team
  belongs_to :parent_assembly, class_name: "Assembly"
  belongs_to :child_assembly, class_name: "Assembly"

  validates :quantity, numericality: { greater_than: 0 }
  validate :not_circular_relation
  validates :parent_assembly, comparison: { other_than: :child_assembly, message: "and Child assembly must be different." }

  def not_circular_relation
    chain = [Assembly.find(parent_assembly_id).name]
    Subassembly.where(parent_assembly_id: child_assembly_id).each do |child_subassembly|
      child_subassembly.circular_relation_check(self, chain.dup)
    end
  end

  def circular_relation_check(subassembly, chain)
    chain << Assembly.find(parent_assembly_id).name
    if child_assembly_id == subassembly.parent_assembly_id
      chain << chain[0]
      subassembly.errors.add :base, "Subassembly would form a circular relation." + "\n(" + chain.join(" \u2794 ") + ")"
    else
      Subassembly.where(parent_assembly_id: child_assembly_id).each do |child_subassembly|
        child_subassembly.circular_relation_check(subassembly, chain.dup)
      end
    end
  end
end
