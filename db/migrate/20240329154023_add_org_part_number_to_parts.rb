# frozen_string_literal: true

class AddOrgPartNumberToParts < ActiveRecord::Migration[7.1]
  def up
    add_column :parts, :org_part_number, :string
    Part.update_all("org_part_number=id+1000000000")
  end

  def down
    remove_column :parts, :org_part_number
  end
end
