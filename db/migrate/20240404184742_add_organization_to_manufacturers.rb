# frozen_string_literal: true

class AddOrganizationToManufacturers < ActiveRecord::Migration[7.1]
  def change
    add_reference :manufacturers, :organization, null: false, foreign_key: true, default: User.any? ? Organization.first.id : nil
  end
end
