# frozen_string_literal: true

class RenamePartCertNumberColumns < ActiveRecord::Migration[7.1]
  def up
    rename_column :parts, :cert_number_1, :optional_field_1
    rename_column :parts, :cert_number_2, :optional_field_2
  end

  def down
    rename_column :parts, :optional_field_1, :cert_number_1
    rename_column :parts, :optional_field_2, :cert_number_2
  end
end
