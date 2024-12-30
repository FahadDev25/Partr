# frozen_string_literal: true

class AddBillingAddressToTeams < ActiveRecord::Migration[7.1]
  def change
    add_reference :teams, :billing_address, null: true, foreign_key:  { to_table: :addresses }
    add_column :teams, :use_org_billing, :boolean
  end
end
