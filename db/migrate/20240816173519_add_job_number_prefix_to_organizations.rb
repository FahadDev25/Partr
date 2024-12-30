# frozen_string_literal: true

class AddJobNumberPrefixToOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :job_number_prefix, :string
  end
end
