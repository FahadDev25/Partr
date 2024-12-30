# frozen_string_literal: true

class RenamePartCertNumberTeamOptions < ActiveRecord::Migration[7.1]
  def up
    rename_column :teams, :show_cert_number_1, :show_optional_part_field_1
    rename_column :teams, :show_cert_number_2, :show_optional_part_field_2
    rename_column :teams, :cert_number_1_name, :optional_part_field_1_name
    rename_column :teams, :cert_number_2_name, :optional_part_field_2_name
  end

  def down
    rename_column :teams, :show_optional_part_field_1, :show_cert_number_1
    rename_column :teams, :show_optional_part_field_2, :show_cert_number_2
    rename_column :teams, :optional_part_field_1_name, :cert_number_1_name
    rename_column :teams, :optional_part_field_2_name, :cert_number_2_name
  end
end
