# frozen_string_literal: true

class AddPartAutosharingToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :share_parts_with, :string
  end
end
