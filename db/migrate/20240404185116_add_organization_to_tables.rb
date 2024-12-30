# frozen_string_literal: true

class AddOrganizationToTables < ActiveRecord::Migration[7.1]
  def up
    add_reference :vendors, :organization, null: false, foreign_key: true, default: User.any? ? Organization.first.id : nil
    change_column :vendors, :organization_id, :bigint, default: nil
    add_reference :units, :organization, null: false, foreign_key: true, default: User.any? ? Organization.first.id : nil
    change_column :units, :organization_id, :bigint, default: nil
    add_reference :shipments, :organization, null: false, foreign_key: true, default: User.any? ? Organization.first.id : nil
    change_column :shipments, :organization_id, :bigint, default: nil
    add_reference :parts_received, :organization, null: false, foreign_key: true, default: User.any? ? Organization.first.id : nil
    change_column :parts_received, :organization_id, :bigint, default: nil
    add_reference :orders, :organization, null: false, foreign_key: true, default: User.any? ? Organization.first.id : nil
    change_column :orders, :organization_id, :bigint, default: nil
    add_reference :line_items, :organization, null: false, foreign_key: true, default: User.any? ? Organization.first.id : nil
    change_column :line_items, :organization_id, :bigint, default: nil
    add_reference :jobs, :organization, null: false, foreign_key: true, default: User.any? ? Organization.first.id : nil
    change_column :jobs, :organization_id, :bigint, default: nil
    add_reference :customers, :organization, null: false, foreign_key: true, default: User.any? ? Organization.first.id : nil
    change_column :customers, :organization_id, :bigint, default: nil
    add_reference :additional_parts, :organization, null: false, foreign_key: true, default: User.any? ? Organization.first.id : nil
    change_column :additional_parts, :organization_id, :bigint, default: nil
  end

  def down
    remove_reference :vendors, :organization
    remove_reference :units, :organization
    remove_reference :shipments, :organization
    remove_reference :parts_received, :organization
    remove_reference :orders, :organization
    remove_reference :line_items, :organization
    remove_reference :jobs, :organization, null: false
    remove_reference :customers, :organization
    remove_reference :additional_parts, :organization
  end
end
