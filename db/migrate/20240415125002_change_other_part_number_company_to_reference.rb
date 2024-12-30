# frozen_string_literal: true

class ChangeOtherPartNumberCompanyToReference < ActiveRecord::Migration[7.1]
  def up
    rename_column :other_part_numbers, :company, :company_name
    add_reference :other_part_numbers, :company, null: true, polymorphic: true
    remove_column :other_part_numbers, :opn_type
  end

  def down
    remove_reference :other_part_numbers, :company
    add_column :other_part_numbers, :opn_type, :string
    remove_column :other_part_numbers, :company_type
    rename_column :other_part_numbers, :company_name, :company
  end
end
