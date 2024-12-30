# frozen_string_literal: true

class AddFaxNumberToOrganization < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :fax_number, :string
  end
end
