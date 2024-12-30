# frozen_string_literal: true

class AddMcmasterApiColumnsToOrganization < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :mcmaster_certificate, :string
    add_column :organizations, :mcmaster_username, :string
    add_column :organizations, :mcmaster_password, :string
  end
end
