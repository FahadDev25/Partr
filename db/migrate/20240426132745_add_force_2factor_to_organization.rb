# frozen_string_literal: true

class AddForce2factorToOrganization < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :force_2fa, :boolean
  end
end
