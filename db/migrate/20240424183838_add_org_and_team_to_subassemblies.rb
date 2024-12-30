# frozen_string_literal: true

class AddOrgAndTeamToSubassemblies < ActiveRecord::Migration[7.1]
  def change
    add_reference :subassemblies, :organization, null: false, foreign_key: true
    add_reference :subassemblies, :team, null: false, foreign_key: true
  end
end
