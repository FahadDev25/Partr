# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :abbr_name
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    Organization.create(name: "Organization", abbr_name: "Org", user_id: User.first.id) if User.any?
  end
end
