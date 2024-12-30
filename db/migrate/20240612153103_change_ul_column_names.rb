# frozen_string_literal: true

class ChangeUlColumnNames < ActiveRecord::Migration[7.1]
  def change
    rename_column :parts, :ul_file_number, :cert_number_1
    rename_column :parts, :ul_ccn, :cert_number_2
  end
end
