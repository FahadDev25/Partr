# frozen_string_literal: true

class AddOrganizationToParts < ActiveRecord::Migration[7.1]
  def change
    add_reference :parts, :organization, null: false, foreign_key: true, default: User.any? ? Organization.first.id : nil
  end
end
