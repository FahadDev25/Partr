# frozen_string_literal: true

class MoveMecoPartNumberToOtherPartNumber < ActiveRecord::Migration[7.1]
  def up
    Part.all.each do |p|
      if p.meco_part_number
        meco = Customer.find_or_create_by(name: "MECO")
        OtherPartNumber.create(part_id: p.id, company_type: "Customer", company_id: meco.id, company_name: meco.name, part_number: p.meco_part_number, organization_id: p.organization_id)
      end
    end
    remove_column :parts, :meco_part_number
  end

  def down
    add_column :parts, :meco_part_number, :string
    meco = Customer.find_by(name: "MECO")
    OtherPartNumber.all.each do |opn|
      if opn.company_name == meco.name
        part = Part.find(opn.part_id)
        part.meco_part_number = opn.part_number
        part.save!
        opn.destroy
      end
    end
  end
end
